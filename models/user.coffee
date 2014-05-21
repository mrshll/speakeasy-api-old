mongoose = require 'mongoose'
Schema = mongoose.Schema

userSchema = mongoose.Schema
  id: Schema.Types.ObjectId
  created_at:
    type: Date
    default: Date.now
  phone_number: String
  password: String

module.exports = mongoose.model 'User', userSchema
