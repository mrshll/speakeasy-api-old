dispatcher = require '../dispatcher'

helpers = require '../helpers'
should = require 'should'
moment = require 'moment'
sinon = require 'sinon'

# DB & Models
dbURI = 'mongodb://localhost/test'
mongoose = require 'mongoose'
clearDB = require('mocha-mongoose')(dbURI)
Message = require '../models/message'
User = require '../models/user'

createUser = (callback) ->
  user = new User
    phone_number: '11111111111'
    password: 'password'
  user.save callback

createMessage = (deliverAt, mediaURI, callback) ->
  createUser (err, user) ->
    message = new Message
      media_uri: mediaURI
      _user: user._id
      deliver_at: deliverAt
      in_progress: false
      completed_at: null
    message.save callback

beforeEach (done) ->
  return done() if mongoose.connection.db
  mongoose.connect dbURI, done

beforeEach (done) ->
  clearDB done

describe 'dispatcher', ->
  describe 'enqueueReadyMessages', ->
    beforeEach (done) ->
      @publishStub = sinon.stub()
      dispatcher.nsq.publish = @publishStub
      done()

    context 'no messages ready', ->
      it 'should not publish a message', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.called.should.be.false
          done()

    context '1 message ready', ->
      beforeEach (done) ->
        createMessage(moment().subtract('minute', 1), 'youareeye', done)

      it 'should publish a message', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.calledOnce.should.be.true
          done()

      it 'it should hydrate the user on the message', (done) ->
        dispatcher.enqueueReadyMessages =>
          message = @publishStub.args[0][1].message
          message._user.should.have.property 'phone_number'
          done()

    context 'messages exist but are in the future', ->
      it 'should not publish a message', (done) ->
        createMessage moment().add('day', 1), 'youareeye', =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'messages exist but do not have a media uri', ->
      it 'should not publish a message', (done) ->
        createMessage moment().subtract('day', 1), null, =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'multiple messages are ready', ->
      beforeEach (done) ->
        createMessage moment().subtract('day', 1), 'youareeye', ->
          createMessage moment().subtract('day', 1), 'youareeye', done

      it 'should publish all the messages', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.calledTwice.should.be.true
          done()
