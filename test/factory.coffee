requirejs = require 'requirejs'

requirejs.define [
  'mongoose'
  'mocha-mongoose'
  '../models/message'
  '../models/user'
], (mongoose, mochaMongoose, Message, User) ->
  new class Factory
    DB_URI: 'mongodb://localhost/test'

    clearDB: -> mochaMongoose(@DB_URI)

    createUser: (callback) ->
      user = new User
        phone_number: '11111111111'
        password: 'password'
      user.save callback

    createMessage: (deliverAt, mediaURI, callback) ->
      @createUser (err, user) ->
        message = new Message
          media_uri: mediaURI
          _user: user._id
          deliver_at: deliverAt
          in_progress: false
          completed_at: null
        message.save callback

    ensureConnectionAndClearDB: (done) ->
      unless mongoose.connection.db
        mongoose.connect @DB_URI, done
      @clearDB()
      done()
