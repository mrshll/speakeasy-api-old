should = require 'should'
moment = require 'moment'
sinon = require 'sinon'

factory = require './factory'
dispatcher = require '../dispatcher'
helpers = require '../helpers'
Message = require '../models/message'

beforeEach (done) ->
  factory.ensureConnectionAndClearDB done

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
        messageParams =
          deliver_at: moment().subtract('minute', 1)
          state: helpers.MSG_STATE_CONVERTED
        factory.createMessage(messageParams, done)

      it 'should publish a message', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.calledOnce.should.be.true
          done()

      it 'should hydrate the user on the message', (done) ->
        dispatcher.enqueueReadyMessages =>
          message = @publishStub.args[0][1].message
          message._user.should.have.property 'phone_number'
          done()

      it "should update the messages' state to enqueued", (done) ->
        dispatcher.enqueueReadyMessages =>
          Message.find { state: helpers.MSG_STATE_ENQUEUED }, (err, messages) ->
            messages.length.should.equal 1
            done()

    context 'messages exist but are in the future', ->
      it 'should not publish a message', (done) ->
        messageParams =
          deliver_at: moment().add('minute', 1)
          state: helpers.MSG_STATE_CONVERTED
        factory.createMessage messageParams, =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'messages exist but do not have a media uri', ->
      it 'should not publish a message', (done) ->
        messageParams =
          deliver_at: moment().subtract('day', 1)
          state: helpers.MSG_STATE_CONVERTED
          media_uri: null
        factory.createMessage messageParams, =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'multiple messages are ready', ->
      beforeEach (done) ->
        messageParams =
          deliver_at: moment().subtract('day', 1)
          state: helpers.MSG_STATE_CONVERTED
        factory.createMessage messageParams, ->
          factory.createMessage messageParams, done

      it 'should publish all the messages', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.calledTwice.should.be.true
          done()
