mongoose = require 'mongoose'
Schema = mongoose.Schema

messageSchema = mongoose.Schema
  id: Schema.Types.ObjectId
  created_at:
    type: Date
    default: Date.now
  deliver_at: Date
  user_id: Schema.Types.ObjectId
  media_url: String

module.exports = mongoose.model 'Message', messageSchema
