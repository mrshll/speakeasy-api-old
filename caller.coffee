if typeof define isnt 'function' then define = require('amdefine')(module)

define [
  'twilio'
  './helpers'
  './models/message'
  './models/user'
  './worker_base'
], (Twilio, helpers, Message, User, WorkerBase) ->
  class Caller extends WorkerBase

    subTopic: helpers.CALLER_TOPIC

    constructor: ->
      super
      @twilio = Twilio helpers.TWILIO_ACCOUNT_SID, helpers.TWILIO_AUTH_TOKEN

    messageHandler: (item, done) ->
      message = item.data.message
      @markMessageAsInProgress message, (err, updatedMessage) ->
        handleError err if err
        user = updatedMessage._user
        @call(user, updatedMessage)
        item.finish()

    # callback takes error and an updated message
    markMessageAsInProgress: (message, done) ->
      Message.findByIdAndUpdate message._id,
        { $set: { state: 'calling' } }, done

    call: (user, message, done) ->
      console.log "initiating call to #{ user.phone_number }"
      params = "message_id=#{ message._id }"
      call =
        to: user.phone_number
        from: "+16159135926"
        url: "#{ helpers.CALLBACK_ROOT_URL }/twilio/callback?#{ params }"

      @twilio.makeCall call, (err, data) ->
        if err
          console.log err
          message.state = 'converted' # send message back to dispatcher
          message.save()
        else
          console.log data

  module.exports = new Caller
