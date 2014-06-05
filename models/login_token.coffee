mongoose = require 'mongoose'
Schema = mongoose.Schema

loginTokenSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  phone_number: String
  token: String
  expires: Date

module.exports = mongoose.model 'LoginToken', loginTokenSchema
