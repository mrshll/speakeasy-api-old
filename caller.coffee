helpers = require './helpers'
###### TWILIO
Twilio = require 'twilio'
twilio = Twilio process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN

# Query db for notifications to dispatch
mongoose = require './db'
Message = require './models/message'
User = require './models/user'

##### QUEUE
NSQClient = require 'nsq-client'
Util = require 'util'
OS = require 'os'

nsq = new NSQClient debug: true

nsq.on "error", (err) ->
  console.log "ERROR " + Util.inspect(err)

nsq.on "debug", (event) ->
  console.log "DEBUG " + Util.inspect(event)

TOPIC = process.env.NSQ_MESSAGE_TOPIC
channel = OS.hostname()

# Subscribe to topics defined on stdin
console.log "Subscribing to #{ TOPIC } / #{ channel }"
subscriber = nsq.subscribe TOPIC, channel, ephemeral: true
subscriber.on "message", (item) ->
  message = item.data.message
  user = message._user
  Message.findByIdAndUpdate message._id, { $set: { in_progress: true } }, (err, updatedMessage) ->
    handleError err if err
    console.log 'updatedMessage' + updatedMessage
    console.log "initiating call to #{ user.phone_number }"
    params = "message_id=#{ updatedMessage._id }"
    call =
      to: user.phone_number
      from: "+16159135926"
      url: "#{ helpers.ROOT_URL }/twilio/callback?#{ params }"

    twilio.makeCall call, (err, data) ->
      if err
        console.log err
        updatedMessage.in_progress = false
        updatedMessage.save()
      else
        console.log data

      item.finish()

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing nsq connections"
  console.log "Press CTL-C again to force quit"
  nsq.close ->
    process.exit()
