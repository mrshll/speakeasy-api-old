helpers = require '../helpers'
helpers = require '../db'
mongoose = require 'mongoose'
Schema = mongoose.Schema

messageSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  sent_at:
    type: Date
  from:
    type: String
  text:
    type: String
  group:
    type: Schema.ObjectId, ref: 'Group'


module.exports = mongoose.model 'Message', messageSchema
