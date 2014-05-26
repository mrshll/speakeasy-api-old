_ = require 'underscore'
moment = require 'moment'
NSQClient = require 'nsq-client'
Util = require "util"

nsq = new NSQClient debug: true

nsq.on "error", (err) ->
  console.log "ERROR " + Util.inspect(err)

nsq.on "debug", (event) ->
  console.log "DEBUG " + Util.inspect(event)

TOPIC = process.env.NSQ_MESSAGE_TOPIC

# Query db for notifications to dispatch
mongoose = require './db'
Message = require './models/message'
User = require './models/user'

# Poll database for messages that need to be enqueued
setInterval (->
  query = Message.find
    'deliver_at':
      '$lte': moment()._d
    'completed_at': null
    'in_progress': false
  query.populate('_user').exec (err, messages) ->
    if messages.length
      console.log "Dispatching #{ messages.length } messages"
      _.each messages, (message) ->
        nsq.publish TOPIC,
          message: message
    else
      console.log 'No messages to enqueue'
), 5000

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing client connections"
  console.log "Press CTL-C again to force quit"
  nsq.close ->
    process.exit()
