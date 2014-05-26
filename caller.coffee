NSQClient = require 'nsq-client'
Util = require "util"

nsq = new NSQClient debug: true

nsq.on "error", (err) ->
  console.log "ERROR " + Util.inspect(err)

nsq.on "debug", (event) ->
  console.log "DEBUG " + Util.inspect(event)

# Subscribe to topics defined on stdin
process.argv.slice(2).forEach (topic) ->
  console.log "Subscribing to " + topic + "/" + channel
  subscriber = client.subscribe topic, channel, ephemeral: true
  subscriber.on "message", (message) ->
    console.log message
    message.finish()

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing client connections"
  console.log "Press CTL-C again to force quit"
  client.close ->
    process.exit()
