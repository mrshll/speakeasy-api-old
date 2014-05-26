mongoose = require 'mongoose'
Schema = mongoose.Schema

messageSchema = mongoose.Schema
  # user:
  #   type: Schema.Types.ObjectId
  #   ref: 'User'
  created_at:
    type: Date
    default: Date.now
  deliver_at: Date
  media_uri: String

module.exports = mongoose.model 'Message', messageSchema
