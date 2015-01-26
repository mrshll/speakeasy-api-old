helpers   = require './helpers'
db        = require  './db'
mandrill  = require('mandrill-api/mandrill');
Message   = require './models/message'
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

users = [
  {
    email: 'cory.dolphin@gmail.com'
    name: 'Cory'
  },
  {
    email: 'mmoutenot@gmail.com',
    name:'Marshall'
  },
  {
    email: 'ryandawidjan@gmail.com'
    name: 'Ryan'
  },
  {
    email: 'jackrmcdermott@gmail.com'
    name: 'Jack'
  },
  {
    email: 'me@hem.al'
    name: 'Hemal'
  }
]

processResults = (err, messages) ->
  messageIds = _.pluck messages, '_id'

  if messages.length == 0
    console.log "No unset messages. Not sending"
    dropTheBass()

  console.log("Called with #{err} #{messages}")

  _.each messages, (message) ->
    message.avatarUrl = gravatar.url(message.from, {s:'100', r: 'x', d: 'retro'}, true)

    userIndex = _.findIndex users, (user) ->
      user.email is message.from

    message.user = users[userIndex]

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
          to: [user]
          headers:
            "Reply-To": "daily-summary@meldly.com"


        mandrill_client.messages.send { message: message}, (result) ->
          cb()

      async.map users, sendDigest, ->
        console.log "marking messages as read"
        Message.update {_id: {$in: messageIds } }, { sent_at: new Date() }, { multi: true }, (messages) ->
          console.log messages
          console.log "successfully marked as read"
        dropTheBass()

sendReminder = (user, cb)->
  message =
    text: "Hey! What did you do today?"
    subject: "Your friends want to know what you did Today"
    from_email: "daily@meldly.com"
    from_name: "The Cortado"
    to: [user]
    headers:
      "Reply-To": "daily@meldly.com"

  mandrill_client.messages.send {
      message: message
    }, (result) ->
    console.log result
    cb()

if process.argv.length == 3
  if process.argv[2] == 'digest'
    console.log "Sending Digest"
    Message.find().where('sent_at': { $gt: new Date((new Date()).getTime() - 1000 * 60*20) }).exec(processResults)
  else if process.argv[2] == 'reminder'
    console.log "Sending reminder!"
    async.map(users, sendReminder, dropTheBass)
else
  console.log "Gimmme a cmd darnmit!"
