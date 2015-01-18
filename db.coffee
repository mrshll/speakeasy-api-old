###### Mongo
mongoHostname = process.env.MONGOLAB_URI || 'mongodb://heroku_app33328043:tf95m3adujdgb3ijmvhlr8l3ve@ds031751.mongolab.com:31751/heroku_app33328043'
mongoose = require 'mongoose'
console.log "Connecting to MongoDB: #{mongoHostname}"

mongoose.connect mongoHostname
db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", callback = ->
  console.log 'connected to mongodb'

module.exports = mongoose
