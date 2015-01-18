helpers   = require './helpers'
db        = require  './db'
mandrill  = require('mandrill-api/mandrill');
Message   = require './models/message'
_         = require 'lodash'
async     = require 'async'
mandrill_client = new mandrill.Mandrill('Zlt_XieBtJWJdSmMNbCImQ')


dropTheBass = (err, results)->
  console.log "Dropping all of the bass"
  process.exit()

users = [{
    email: "wcdolphin@gmail.com"
    name: "Cory Dolphin"
  },
  {
    email: 'mmoutenot@gmail.com',
    name:'Marhsall Moutenot'
  }
]

processResults = (err, messages) ->
  console.log("Called with #{err} #{messages}")
  summaryText = _.reduce messages, ((acc, message) ->
    "#{acc} \n #{message.text} from: #{message.from}"), ""

  sendDigest = (user, cb)->
    message =
      text: "Here's what your crew did today \n #{summaryText}"
      subject: "Daily Cortado"
      from_email: "daily@meldly.com"
      from_name: "The Cortado"
      to: [user]
      headers:
        "Reply-To": "daily-summary@meldly.com"

    mandrill_client.messages.send { message: message}, (result) ->
      console.log result
      cb()

  async.map(users, sendDigest, dropTheBass)



sendReminder = (user, cb)->
  message =
    text: "Hey! What did you do today?"
    subject: "Your friends want to know what you did today"
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
    Message.find().where('sent_at', null).exec(processResults)
  else if process.argv[2] == 'reminder'
    console.log "Sending reminder!"
    async.map(users, sendReminder, dropTheBass)
else
  console.log "Gimmme a cmd darnmit!"
