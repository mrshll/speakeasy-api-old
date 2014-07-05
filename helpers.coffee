if typeof define isnt 'function' then define = require('amdefine')(module)
define [
  'crypto'
  'moment'
  'underscore',
  './models/user'
], (crypto, moment, _, User) ->
  class Helpers
    #TODO raise error on startup if any required params are not set, or add defaults to all
    PORT: process.env.PORT
    CALLBACK_ROOT_URL: process.env.CALLBACK_ROOT_URL || "http://localhost"
    DEBUG: process.env.APP_ENV is 'debug'

    # Queue topics
    CONVERTER_TOPIC: process.env.NSQ_CONVERTER_TOPIC || 'mp4_converter_topic'
    CALLER_TOPIC: process.env.NSQ_CALLER_TOPIC || 'caller_topic'
    NSQ_CHANNEL: 'me.futurephone'
    NSQ_DEBUG: false

    # Message States. Used to track messages as they move through the pipeline.
    MSG_STATE_CREATED: 'created'
    MSG_STATE_CONVERTED: 'converted'
    MSG_STATE_ENQUEUED: 'enqueued'
    MSG_STATE_CALLING: 'calling'
    MSG_STATE_COMPLETED: 'completed'


    # Twilio
    TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID || 'AC95819529a22e43ee87a169c2cbbfcd47'
    TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN || '607d3d66b03e03d6b07a2fa26e729277'
    TWILIO_FROM_PHONE: process.env.TWILIO_FROM_PHONE || '3608136598'

    calculateFutureDelivery: (unit, magnitude) ->
      moment().add unit, parseInt(magnitude)

    randomToken: ->
      length = 4
      randomBytes = crypto.randomBytes(length)
      code = []
      for i in [0...length]
        code[i] = randomBytes[i] % 10
      code.join ''

    debug: (msg) ->
      console.log msg if process.env.APP_ENV is 'debug'

    ###### MIDDLEWARE

    # Custom middleware to output route in debug mode
    outputRequestRoute: (req, res, next) =>
      @debug "#{ req.originalUrl } #{ req.method }"
      next()

    # This can be set by tests to allow a single unauth'ed request through
    allowOneUnauthenticatedRequest: false

    # These whitelisted routes do not require a logged in session
    publicRoutes: [
      '/login/phone_number'
      '/login/validate_token'
      '/twilio/callback'
    ]

    # Authentication middleware
    requireAuthentication: (req, res, next) =>
      @debug req.session
      @debug req.cookies
      if _.contains @publicRoutes, req._parsedUrl.pathname
        next()
      else if req.session and req.session.loggedIn
	@debug 'logged in'
        next()
        return
      else if @allowOneUnauthenticatedRequest
        @allowOneUnauthenticatedRequest = false
        next()
      else
        res.send 404, "Must be logged in to access #{ req.url }"

  module.exports = new Helpers
