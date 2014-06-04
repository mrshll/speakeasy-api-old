should = require 'should'
sinon = require 'sinon'
fs = require 'fs'

factory = require './factory'
caller = require '../caller'

describe 'caller', ->
  describe 'markMessageAsInProgress', ->
    beforeEach (done) ->
      factory.createMessage {}, (err, @message) => done()

    it 'should update message in_progress to be true', (done) ->
      @message.in_progress.should.equal false
      caller.markMessageAsInProgress @message, (err, updatedMessage) ->
        updatedMessage.in_progress.should.equal true
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
      it 'should no longer be in progress', (done) ->
        makeCallSpy = sinon.spy()
        caller.twilio.makeCall = makeCallSpy

        caller.call(@user, @message)
        # calls makeCall's callback with the provided arguments
        # This is so so so cool
        makeCallSpy.yield('ERROR', {})

        @message.in_progress.should.equal false
        done()
