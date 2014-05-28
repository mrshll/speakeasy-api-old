_ = require 'underscore'
NSQClient = require 'nsq-client'
Util = require 'util'
FFmpeg = require 'fluent-ffmpeg'
helpers = require './helpers'
OS = require 'os'

# Query db for notifications to dispatch
mongoose = require './db'
Message = require './models/message'
User = require './models/user'

CONVERTER_TOPIC = process.env.NSQ_CONVERTER_TOPIC
channel = OS.hostname()

nsq = new NSQClient debug: helpers.DEBUG
nsq.on "error", (err) ->
  console.log "ERROR " + Util.inspect(err)

nsq.on "debug", (event) ->
  console.log "DEBUG " + Util.inspect(event)

updateMessageWithConvertedFile = (message, path) ->
  media_uri = "#{ helpers.ROOT_URL }/#{ path }"
  Message.findByIdAndUpdate message._id, { $set: { media_uri: media_uri }}, (err, updatedMessage) ->
    handleError err if err
    console.log 'updatedMessage' + updatedMessage

# Subscribe to topics defined on stdin
console.log "Subscribing to #{ CONVERTER_TOPIC } / #{ channel }"
subscriber = nsq.subscribe CONVERTER_TOPIC, channel, ephemeral: true
subscriber.on "message", (item) ->
  message = item.data.message

  destination = message.original_media_path.replace /\.m4a$/, '.mp3'
  console.log "converting #{ message.original_media_path } to #{ destination }"
  new FFmpeg { source: message.original_media_path }
    .withNoVideo()
    .withAudioBitrate '128k'
    .withAudioChannels 2
    .withAudioFrequency 44100
    .withAudioQuality 5
    .fromFormat 'm4a'
    .toFormat 'mp3'
    .on 'error', (err) ->
      #TODO do something real with erros
      console.log err
    .on 'end', ->
      console.log 'conversion complete'
      updateMessageWithConvertedFile(message, destination)
      item.finish()
    .saveToFile destination

# Close connections on exit
process.once "SIGINT", ->
  process.once "SIGINT", process.exit
  console.log()
  console.log "Closing nsq connections"
  console.log "Press CTL-C again to force quit"
  nsq.close ->
    process.exit()
