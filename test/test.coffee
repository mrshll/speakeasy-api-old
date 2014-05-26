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

beforeEach (done) ->
  return done() if  mongoose.connection.db
  mongoose.connect dbURI, done

beforeEach (done) ->
  clearDB done

describe '/twilio/callback', ->
  context 'POST', ->
    beforeEach (done) ->
      @req = request.post('/twilio/callback')
      done()

    it 'should return valid TwiML', (done) ->
      @req.expect('Content-Type', /xml/).end (err, res) ->
        throw err if err
        done()

describe '/messages', ->
  context 'POST with valid params', ->
    params =
      delivery:
        unit: 'days'
        magnitude: 6
      media_uri: 'abc/asdf/wer.mp3'

    beforeEach (done) ->
      @req = request.post('/messages').send(params)
      done()

    it 'should create a message', (done) ->
      @req.expect(201).end (err, res) ->
        throw err if err
        Message.find {}, (err, messages) ->
          messages.length.should.equal 1
          message = messages[0]
          message.should.have.property('media_uri').and.equal params.media_uri
          message.should.have.property('deliver_at')
          moment(message.deliver_at).isAfter(moment()).should.equal true
        done()

describe '/media', ->
  describe 'POST', ->
    context 'no file attached', ->
      beforeEach (done) ->
        @req = request.post '/media'
        done()

      it 'should respond 422', (done) ->
        @req.end (err, res) ->
          done()

    context 'file attached', ->
      beforeEach (done) ->
        @req = request.post('/media').attach('media', 'assets/fixtures/first_call.mp3')
        done()

      it 'should upload the file', (done) ->
        @req.end (err, res) ->
          throw err if err
          res.body.media_uri.match(/http:\/\/.*\/uploads\/.*\.mp3/).should.have.lengthOf 1
          done()

describe 'helpers', ->
  describe '#calculateFutureDelivery', ->
    it 'should return a date in the future', (done) ->
      delivery = unit: 'days', magnitude: 6
      now = moment()
      future_date = helpers.calculateFutureDelivery delivery
      future_date.isAfter(now).should.equal true
      done()
