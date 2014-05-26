###### Mongo
mongoHostname = process.env.MONGO_URL || 'mongodb://localhost/test'
mongoose = require 'mongoose'
console.log "Connecting to MongoDB: #{mongoHostname}"

mongoose.connect mongoHostname
db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", callback = ->
  console.log 'connected to mongodb'

module.exports = mongoose
