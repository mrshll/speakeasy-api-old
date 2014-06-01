should = require 'should'
moment = require 'moment'
sinon = require 'sinon'

factory = require './factory'
dispatcher = require '../dispatcher'
helpers = require '../helpers'

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
        factory.createMessage(moment().subtract('minute', 1), 'youareeye', done)

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
        factory.createMessage moment().add('day', 1), 'youareeye', =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'messages exist but do not have a media uri', ->
      it 'should not publish a message', (done) ->
        factory.createMessage moment().subtract('day', 1), null, =>
          dispatcher.enqueueReadyMessages =>
            @publishStub.called.should.be.false
            done()

    context 'multiple messages are ready', ->
      beforeEach (done) ->
        factory.createMessage moment().subtract('day', 1), 'youareeye', ->
          factory.createMessage moment().subtract('day', 1), 'youareeye', done

      it 'should publish all the messages', (done) ->
        dispatcher.enqueueReadyMessages =>
          @publishStub.calledTwice.should.be.true
          done()
