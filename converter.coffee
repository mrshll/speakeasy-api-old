if typeof define isnt 'function' then define = require('amdefine')(module)

define [
  'fluent-ffmpeg'
  './helpers'
  './worker_base'
  './models/message'
], (FFmpeg, helpers, WorkerBase, Message) ->
  class Converter extends WorkerBase

    subTopic: helpers.CONVERTER_TOPIC

    messageHandler: (job) ->
      message = job.data.message
      console.log "Converter: received message #{ message.original_media_path }"
      @convertM4AToMP3 message.original_media_path, (destination) =>
        console.log 'Converter: conversion complete'
        @updateMessageWithConvertedFile message, destination, (err, updatedMessage) ->
          job.finish()

    # given a path to an m4a file, it returns the path to the new converted mp3
    convertM4AToMP3: (m4aPath, callback) ->
      destination = m4aPath.replace /\.m4a$/, '.mp3'
      console.log "Converter: converting #{ m4aPath } to #{ destination }"
      new FFmpeg { source: m4aPath }
        .withNoVideo()
        .withAudioBitrate '128k'
        .withAudioChannels 2
        .withAudioFrequency 44100
        .withAudioQuality 5
        .fromFormat 'm4a'
        .toFormat 'mp3'
        .on 'error', (err) ->
          #TODO do something real with errors
          console.log err
        .on 'end', ->
          callback destination
        .saveToFile destination

    updateMessageWithConvertedFile: (message, path, callback) ->
      media_uri = "#{ helpers.CALLBACK_ROOT_URL }/#{ path }"
      messageUpdate =
        $set:
          media_uri: media_uri
          state: helpers.MSG_STATE_CONVERTED
      Message.findByIdAndUpdate message._id, messageUpdate, (err, updatedMessage) ->
        handleError err if err
        callback(err, updatedMessage)

  module.exports = new Converter
