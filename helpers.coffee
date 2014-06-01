moment = require 'moment'

helpers =
  ROOT_URL: process.env.ROOT_URL || 'http://localhost:7076'
  DEBUG: process.env.APP_ENV is 'debug'

  # Queue topics
  CONVERTER_TOPIC: process.env.NSQ_CONVERTER_TOPIC

  calculateFutureDelivery: (unit, magnitude) ->
    moment().add unit, parseInt(magnitude)

  debug: (msg) ->
    console.log msg if process.env.APP_ENV is 'debug'

module.exports = helpers
