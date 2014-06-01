should = require 'should'
fs = require 'fs'
path = require 'path'

factory = require './factory'
converter = require '../converter'

beforeEach (done) ->
  debugger
  factory.ensureConnectionAndClearDB done

describe 'converter', ->
  describe 'convertM4AToMp3', ->
    m4aPath = 'assets/fixtures/test.m4a'

    it 'should create an mp3 at the correct destination', (done) ->
      converter.convertM4AToMP3 m4aPath, (destination) ->
        destination.should.equal 'assets/fixtures/test.mp3'
        fs.exists destination , (exists) ->
          exists.should.equal true
          done()

  describe 'updateMessageWithConvertedFile', ->
    it 'should updated the message with the converted file', ->



