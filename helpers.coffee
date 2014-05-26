moment = require 'moment'

helpers =
  calculateFutureDelivery: (delivery) ->
    moment().add delivery.unit, delivery.magnitude

  debug: (msg) ->
    console.log msg if process.env.APP_ENV is 'debug'

module.exports = helpers
