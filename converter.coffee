requirejs = require 'requirejs'
requirejs.config nodeRequire: require

requirejs [
  'fluent-ffmpeg'
  './helpers'
  './worker_base'
], (FFmpeg, helpers, WorkerBase) ->
  class Converter extends WorkerBase

    topic: helpers.CONVERTER_TOPIC

    messageHandler: (message, done) ->
      @convertM4AToMP3 message.original_media_path, (destination) ->
        @updateMessageWithConvertedFile message, destination
        done()

    # given a path to an m4a file, it returns the path to the new converted mp3
    convertM4AToMP3: (m4aPath, callback) ->
      destination = m4aPath.replace /\.m4a$/, '.mp3'
      console.log "converting #{ m4aPath } to #{ destination }"
      new FFmpeg { source: m4aPath }
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
          callback destination
        .saveToFile destination

    updateMessageWithConvertedFile: (message, path) ->
      media_uri = "#{ helpers.ROOT_URL }/#{ path }"
      Message.findByIdAndUpdate message._id, { $set: { media_uri: media_uri }}, (err, updatedMessage) ->
        handleError err if err
        console.log 'updatedMessage' + updatedMessage

  module.exports = new Converter
