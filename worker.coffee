helpers = require './helpers'
db      = require  './db'
mandrill = require('mandrill-api/mandrill');
mandrill_client = new mandrill.Mandrill('Zlt_XieBtJWJdSmMNbCImQ')

Messages.find
  sent_at: null


sendReminder = (users)->
  message =
    text: "Hey! What did you do today?"
    subject: "Your friends want to know what you did today"
    from_email: "daily@meldly.com"
    from_name: "The Cortado"
    to: users
    headers:
      "Reply-To": "daily@meldly.com"

  mandrill_client.messages.send {
      message: message
    }, (result) ->
    console.log result


[{
    email: "wcdolphin@gmail.com"
    name: "Cory Dolphin"
  },
  {
    email: 'mmoutenot@gmail.com',
    name:'Marhsall Moutenot'
  }
].map(sendReminder)

ser
 # Two types of emails
 # Send reminder // 6PM
 # Send summary // 8AM
