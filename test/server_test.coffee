_ = require 'underscore'
should = require 'should'
request = require 'supertest'
moment = require 'moment'

app = require '../server'
request = request(app)

helpers = require '../helpers'

# DB & MODELS
dbURI = 'mongodb://localhost/test'
mongoose = require 'mongoose'
clearDB = require('mocha-mongoose')(dbURI)
Message = require '../models/message'
User = require '../models/user'

createUser = (callback) ->
  user = new User
    phone_number: '16155197142'
    password: 'rogerrogerroger'
  user.save callback

createMessage = (callback) ->
  createUser (err, user) ->
    message = new Message
      deliver_at: moment()._id
      media_uri: 'assets/fixtures/first_call.mp3'
      _user: user._id
    message.save callback

beforeEach (done) ->
  return done() if  mongoose.connection.db
  mongoose.connect dbURI, done

beforeEach (done) ->
  clearDB done

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
        createMessage (err, @message) =>
          @req = request.post("/twilio/callback?message_id=#{ message._id }")
          done()

      it 'should return valid TwiML', (done) ->
        @req.expect('Content-Type', /xml/).end (err, res) =>
          throw err if err
          res.text.match(/xml.*Play.*\.mp3/).should.have.lengthOf 1

          Message.findById @message._id, (err, message) ->
            console.log message
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
        createUser (err, @user) =>
          @req = request.post('/messages')
            .field('delivery_unit', 'days')
            .field('delivery_magnitude', 6)
            .field('user_id', @user._id.toString())
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
            message.should.have.property('media_uri')

            # Check user relation
            message.should.have.property('_user')
            message._user.toString().should.equal @user._id.toString()

            moment(message.deliver_at).isAfter(moment()).should.equal true
          done()

describe 'helpers', ->
  describe '#calculateFutureDelivery', ->
    it 'should return a date in the future', (done) ->
      now = moment()
      future_date = helpers.calculateFutureDelivery 'days', 6
      future_date.isAfter(now).should.equal true
      done()
