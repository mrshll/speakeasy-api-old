should = require 'should'
fs = require 'fs'
path = require 'path'
moment = require 'moment'

factory = require './factory'
converter = require '../converter'

m4aPath = 'assets/fixtures/test.m4a'
mp3DesiredPath = 'assets/fixtures/test.mp3'

beforeEach (done) ->
  fs.unlinkSync(mp3DesiredPath) if fs.existsSync(mp3DesiredPath)
  factory.ensureConnectionAndClearDB done

describe 'converter', ->
  describe 'convertM4AToMp3', ->

    it 'should create an mp3 at the correct destination', (done) ->
      converter.convertM4AToMP3 m4aPath, (destination) ->
        destination.should.equal mp3DesiredPath
        fs.exists destination , (exists) ->
          exists.should.equal true
          done()

  describe 'updateMessageWithConvertedFile', ->
    beforeEach (done) ->
      factory.createMessage {}, (err, @message) => done()

    it 'should update the message with the converted file', (done) ->
      converter.updateMessageWithConvertedFile @message, 'youareeye.mp3', (err, updatedMessage) ->
        updatedMessage.media_uri.should.equal "http://localhost/youareeye.mp3"
      done()
