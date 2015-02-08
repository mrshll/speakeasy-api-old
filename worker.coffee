helpers   = require './helpers'
db        = require  './db'
mandrill  = require('mandrill-api/mandrill');
Message   = require './models/message'
Group     = require './models/group'
moment    = require 'moment'
_         = require 'lodash'
async     = require 'async'
gravatar  = require 'gravatar'

path = require('path')
mandrill_client = new mandrill.Mandrill('Zlt_XieBtJWJdSmMNbCImQ')
templatesDir = path.join(__dirname, 'templates')
emailTemplates = require('email-templates')

dropTheBass = (err, results)->
  console.log "Dropping all of the bass"
  process.exit()

sendDigestForGroup = (group, cb) ->
  Message.find().where({ 'sent_at': null, 'group': group.id })
    .populate('user')
    .exec (err, messages) ->
      fn = getSendToUserFn(messages)
      async.map(group.users, fn, cb)

getSendToUserFn = (messages) ->
  (user, cb) ->
    messageIds = _.pluck messages, '_id'

    if messages.length == 0
      console.log "No unset messages. Not sending"
      dropTheBass()

    console.log("Called with #{err} #{messages}")

    _.each messages, (message) ->
      message.avatarUrl = gravatar.url(message.user.email, {s:'100', r: 'x', d: 'retro'}, true)

    locals = messages: messages
    emailTemplates templatesDir, (err, template) ->
      template 'daily', locals, (err, html, text) ->
        console.log "Error: #{ err }"
        sendDigest = (user, cb)->
          message =
            html: html
            subject: "Daily Cortado for #{moment().format('MMM Do YY')}"
            from_email: "daily@meldly.com"
            from_name: "The Cortado"
            to: [user.email]
            headers:
              "Reply-To": "daily-summary@meldly.com"


          mandrill_client.messages.send { message: message }, (result) ->
            cb()

        async.map users, sendDigest, ->
          console.log "marking messages as read"
          Message.update {_id: {$in: messageIds } }, { sent_at: new Date() }, { multi: true }, (messages) ->
            console.log messages
            console.log "successfully marked as read"
            dropTheBass()

sendReminder = (group, cb)->
  console.log group
  sendUserReminder = (user, _cb) ->
    message =
      text: "Reply with a few sentences that #{group.name} should know about."
      subject: "Tell #{group.name} about your day"
      from_email: "daily.#{group.name}@meldly.com"
      from_name: group.name
      to: [user]
      headers:
        "Reply-To": "daily.#{group.name}@meldly.com"

    console.log message
    mandrill_client.messages.send {
        message: message
      }, (result) ->
      console.log result
      _cb()

  async.map(group.users, sendUserReminder, cb)

#      Group.findOne('Cortado').populate('users').exec (err, res) ->

if process.argv.length == 3
  if process.argv[2] == 'digest'
    console.log "Sending Digest"
    Group.find(name:'test').populate('users').exec (err, groups) ->
      async.map(groups, sendDigestForGroup, dropTheBass)

  else if process.argv[2] == 'reminder'
    console.log "Sending reminder!"
    Group.find().populate('users').exec (err, groups) ->
      async.map(groups, sendReminder, dropTheBass)
else
  console.log "Gimmme a cmd darnmit!"
