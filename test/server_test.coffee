_ = require 'underscore'
should = require 'should'
request = require 'supertest'
sinon = require 'sinon'
moment = require 'moment'

webServer = require '../server'
sessionStore = webServer.sessionStore
helpers = require '../helpers'
factory = require './factory'
Message = require '../models/message'
User = require '../models/user'
LoginToken = require '../models/login_token'

request = request(webServer.app)

sessionStore.firstSession = (callback) ->
  firstSessionId = Object.keys(sessionStore.sessions)[0]
  sessionStore.get firstSessionId, callback

beforeEach (done) ->
  factory.ensureConnectionAndClearDB done

describe '/twilio/callback', ->
  context 'POST', ->
    context 'with invalid params', ->
      beforeEach (done) ->
        @req = request.post("/twilio/callback?message_id=")
        done()

      it 'should respond 422', (done) ->
        @req.expect(422).end (err, res) ->
          throw err if err
          done()

    context 'with valid params', ->
      beforeEach (done) ->
        factory.createMessage {}, (err, @message) =>
          @req = request.post("/twilio/callback?message_id=#{ message._id }")
          done()

      it 'should return valid TwiML', (done) ->
        @req.expect('Content-Type', /xml/).end (err, res) =>
          throw err if err
          res.text.match(/xml.*Play.*\.mp3/).should.have.lengthOf 1

          Message.findById @message._id, (err, message) ->
            moment(message.completed_at).isBefore(moment()).should.equal true
            done()

describe '/messages', ->
  context 'POST', ->
    context 'with no file attached', ->
      beforeEach (done) ->
        @req = request.post '/media'
        done()

      it 'should respond 422', (done) ->
        @req.end (err, res) ->
          done()

    context 'with valid params', ->
      beforeEach (done) ->
        factory.createUser {}, (err, @user) =>
          @req = request.post('/messages')
            .field('delivery_unit', 'days')
            .field('delivery_magnitude', 6)
            .field('phone_number', @user.phone_number)
            .field('session_key', 'abc123')
            .attach('media', 'assets/fixtures/first_call.mp3')
          done()

      it 'should create a message', (done) ->
        @req.expect(201).end (err, res) =>
          throw err if err
          Message.find {}, (err, messages) =>
            messages.length.should.equal 1
            message = messages[0]
            message.should.have.property('_user')
            message.should.have.property('in_progress')
            message.should.have.property('deliver_at')
            message.should.have.property('original_media_path')

            # Check user relation
            message.should.have.property('_user')
            message._user.toString().should.equal @user._id.toString()

            moment(message.deliver_at).isAfter(moment()).should.equal true
          done()

PHONE_NUMBER = '1111111111'
describe '/login/phone_number', ->
  context 'POST', ->
    beforeEach (done) ->
      @req = request.post '/login/phone_number'
               .field 'phone_number', PHONE_NUMBER
      done()

    context 'success', ->
      beforeEach (done) ->
        @sendMessageStub = sinon.stub().yields()
        webServer.twilio.sendMessage = @sendMessageStub
        done()

      it 'creates a login token', (done) ->
        @req.expect(200).end (err, res) =>
          findToken = LoginToken.findOne
            phone_number: PHONE_NUMBER
            expires:
              $gt: moment()
          findToken.exec().then (tokenRecord, err) =>
            tokenRecord.token.length.should.equal 6
            done()

      it 'sends a token message to twilio', (done) ->
        @req.expect(200).end (err, res) =>
          throw err if err
          @sendMessageStub.calledOnce.should.be.true
          done()

    context 'twilio send message returns an error', ->
      beforeEach (done) ->
        @sendMessageStub = sinon.stub().yields "error", null
        webServer.twilio.sendMessage = @sendMessageStub
        done()

      it 'returns 400', (done) ->
        @req.expect(400).end done

TOKEN = '123456'
describe '/login/validate_token', ->
  context 'POST', ->
    beforeEach (done) ->
      sessionStore.clear()
      LoginToken.create {
        phone_number: PHONE_NUMBER
        token: TOKEN
        expires: moment().add 'minutes', 10
      }, done

    context 'success', ->
      beforeEach (done) ->
        @req = request.post '/login/validate_token'
                 .field 'phone_number', PHONE_NUMBER
                 .field 'token', TOKEN
        done()

      it 'returns 200', (done) ->
        @req.expect(200).end done

      it 'sets the users session state to logged in', (done) ->
        @req.expect(200).end (err, res) ->
          sessionStore.firstSession (err, session) ->
            session.should.have.property('loggedIn')
            session.loggedIn.should.be.true
            done()

    context 'incorrect token', ->
      beforeEach (done) ->
        @req = request.post '/login/validate_token'
                 .field 'phone_number', PHONE_NUMBER
                 .field 'token', 'wrongtoken'
        done()

      it 'returns 404', (done) ->
        @req.expect(404).end done

      it 'does not log the user in', (done) ->
        @req.end (err, res) ->
          sessionStore.firstSession (err, session) ->
            session.should.not.have.property('loggedIn')
            done()

    context 'expired token', ->
      beforeEach (done) ->
        @req = request.post '/login/validate_token'
                 .field 'phone_number', PHONE_NUMBER
                 .field 'token', '888888'
        LoginToken.create {
          phone_number: PHONE_NUMBER
          token: '888888'
          expires: moment().subtract 'minutes', 1
        }, done

      it 'returns 404', (done) ->
        @req.expect(404).end done
