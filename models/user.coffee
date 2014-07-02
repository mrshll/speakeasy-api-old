mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  phone_number: String

module.exports = mongoose.model 'User', userSchema
