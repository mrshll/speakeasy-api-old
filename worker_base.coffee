if typeof define isnt 'function' then define = require('amdefine')(module)
define [
  'underscore'
  'nsq-client'
  'util'
  'os'
  './helpers'
  './db'
  './models/message'
  './models/user'
], (_, NSQClient, Util, OS, helpers, mongoose, Message, User) ->
  class WorkerBase
    channel: helpers.NSQ_CHANNEL

    constructor: ->
      @nsq = new NSQClient debug: helpers.NSQ_DEBUG
      @nsq.on "error", (err) ->
        console.log "ERROR " + Util.inspect(err)

      @nsq.on "debug", (event) ->
        console.log "DEBUG " + Util.inspect(event)

      # Subscribe to topics defined on stdin
      if @subTopic
        console.log "Subscribing to #{ @subTopic } / #{ @channel }"
        subscriber = @nsq.subscribe @subTopic, @channel, ephemeral: true

        subscriber.on "message", (message) =>
          @messageHandler message, item.finish

      @registerExitCallback()

    messageHandler: (message, done) ->
      console.log message
      done()

    enqueueMessage: (message) ->
      @nsq.publish @pubTopic, message: message

    registerExitCallback: ->
      # Close connections on exit
      process.once "SIGINT", =>
        process.once "SIGINT", process.exit
        console.log()
        console.log "Closing nsq connections"
        console.log "Press CTL-C again to force quit"
        @nsq.close ->
          process.exit()
