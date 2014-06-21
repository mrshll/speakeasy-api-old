should = require 'should'
sinon = require 'sinon'
fs = require 'fs'

helpers = require '../helpers'
factory = require './factory'
caller = require '../caller'

describe 'caller', ->
  describe 'markMessageAsInProgress', ->
    beforeEach (done) ->
      messageParams = state: helpers.MSG_STATE_ENQUEUED
      factory.createMessage messageParams, (err, @message) => done()

    it 'should update message state to "calling"', (done) ->
      @message.state.should.equal helpers.MSG_STATE_ENQUEUED
      caller.markMessageAsInProgress @message, (err, updatedMessage) ->
        updatedMessage.state.should.equal helpers.MSG_STATE_CALLING
        done()

  describe 'call', ->

    beforeEach (done) ->
      factory.createUser {}, (err, @user) =>
        factory.createMessage { _user: @user.id }, (err, @message) => done()

    context 'call was successful', ->
      it 'should call the user\'s number with the message', (done) ->
        makeCallSpy = sinon.spy()
        caller.twilio.makeCall = makeCallSpy

        caller.call(@user, @message)
        makeCallSpy.called.should.equal.true
        done()

    context 'call was unsuccessful', ->
      it 'should mark the message as converted (ready to be enqueued again)', (done) ->
        makeCallSpy = sinon.spy()
        caller.twilio.makeCall = makeCallSpy

        caller.call(@user, @message)
        # calls makeCall's callback with the provided arguments
        # This is so so so cool
        makeCallSpy.yield('Example Error', {})

        @message.state.should.equal helpers.MSG_STATE_CONVERTED
        done()
