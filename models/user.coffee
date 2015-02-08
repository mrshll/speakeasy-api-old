helpers = require '../helpers'
helpers = require '../db'
findOrCreate = require 'mongoose-findorcreate'
mongoose = require 'mongoose'

Schema = mongoose.Schema

userSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  name:
    type: String
  email:
    type: String
    index:
      unique: true
userSchema.plugin findOrCreate

module.exports = mongoose.model 'User', userSchema
