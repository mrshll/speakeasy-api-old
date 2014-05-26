moment = require 'moment'

helpers =
  ROOT_URL: process.env.ROOT_URL || 'http://localhost:7076'

  calculateFutureDelivery: (delivery) ->
    moment().add delivery.unit, delivery.magnitude

  debug: (msg) ->
    console.log msg if process.env.APP_ENV is 'debug'

module.exports = helpers
