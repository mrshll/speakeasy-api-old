###### WEBSERVER

express = require 'express.io'
app = express()
app.http().io()

app.post '/twilio/callback', (req, res) ->
  resp = new Twilio.TwimlResponse()
  resp.play "#{ ROOT_URL }/fixtures/second_call.mp3"
  res.header('Content-Type','text/xml').send resp.toString()

###### TWILIO
Twilio = require 'twilio'
twilio = Twilio process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN

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
subscriber.on "message", (message) ->
  console.log message

  call =
    to: message.user.phone_number
    from: "+16159135926"
    url: "#{ ROOT_URL }/twilio/callback"

  twilio.makeCall call, (err, data) ->
    if err
      helpers.debug err
    else
      helpers.debug data

  message.finish()

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing nsq connections"
  console.log "Press CTL-C again to force quit"
  nsq.close ->
    process.exit()
