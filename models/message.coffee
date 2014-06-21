helpers = require '../helpers'
mongoose = require 'mongoose'
Schema = mongoose.Schema

messageSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  deliver_at: Date
  completed_at:
    type: Date
    default: null
  # state can be one of 'created', 'converted', 'enqueued', 'calling', 'completed'
  state:
    type: String
    default: helpers.MSG_STATE_CREATED
  original_media_path: String
  media_uri:
    type: String
    default: null
  _user:
    type: Schema.Types.ObjectId
    ref: 'User'

module.exports = mongoose.model 'Message', messageSchema
