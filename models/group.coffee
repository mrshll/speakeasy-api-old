helpers = require '../helpers'
db = require '../db'
User = require '../models/user'
mongoose = require 'mongoose'
Schema = mongoose.Schema

groupSchema = mongoose.Schema
  created_at:
    type: Date
    default: Date.now
  name:
    type: String
  users: [{ type: Schema.ObjectId, ref: 'User' }]
  admins: # the list of email addresses which are admin for this group
    type: Array
    default: []

groupSchema.methods.addUser = (userData) ->
  return unless userData.email
  userData.email = userData.email.toLowerCase()

  add = (user) =>
    this.users.push(user._id)
    this.save()

  User.findOne({email:userData.email}).exec (err, user)->
    if not user
      User.create(userData).then add
    else
      add user


module.exports = mongoose.model 'Group', groupSchema
