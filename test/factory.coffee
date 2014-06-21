if typeof define isnt 'function' then define = require('amdefine')(module)

define [
  'underscore'
  'mongoose'
  'mocha-mongoose'
  'moment'
  '../models/message'
  '../models/user'
], (_, mongoose, mochaMongoose, moment, Message, User) ->
  class Factory
    DB_URI: 'mongodb://localhost/test'

    clearDB: -> mochaMongoose(@DB_URI)

    createUser: (params, callback) ->
      user = new User
        phone_number: params.phone_number || '12345678'
        password: params.password || 'password'
      user.save callback

    createMessage: (params, callback) ->
      @createUser {}, (err, user) ->
        _.defaults params,
          media_uri: 'http://test.com/youareeye.mp3'
          original_media_path: 'youareeye.m4a'
          _user: user._id
          deliver_at: moment()
          completed_at: null

        new Message(params).save callback

    ensureConnectionAndClearDB: (done) ->
      unless mongoose.connection.db
        mongoose.connect @DB_URI, done
      @clearDB()
      done()

  module.exports = new Factory
