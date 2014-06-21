if typeof define isnt 'function' then define = require('amdefine')(module)
define [
  'underscore'
  'moment'
  './helpers'
  './worker_base'
  './models/message'
  './models/user'
], (_, moment, helpers, WorkerBase, Message, User) ->
  class Dispatcher extends WorkerBase
    pubTopic: helpers.CALLER_TOPIC
    constructor: ->
      super
      # Poll database for messages that need to be enqueued
      setInterval @enqueueReadyMessages, 5000

    # Enqueue messages which are ready to be called
    # If provided, calls done with the number of dispatched messages
    enqueueReadyMessages: (done) =>
      query = Message.find
        deliver_at:
          $lte: moment()._d
        completed_at: null
        state: helpers.MSG_STATE_CONVERTED
        media_uri:
          $ne: null

      query.populate('_user').exec (err, messages) =>
        if messages.length
          messageIds = []
          console.log "Dispatching #{ messages.length } messages"
          _.each messages, (message) =>
            @enqueueMessage message
            messageIds.push message._id
          updateQuery = { _id: { $in: messageIds } }
          Message.update updateQuery, { state: helpers.MSG_STATE_ENQUEUED }, ->
            done messages.length if done
        else
          console.log 'No messages to enqueue'
          done 0 if done

  module.exports = new Dispatcher
