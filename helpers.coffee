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
