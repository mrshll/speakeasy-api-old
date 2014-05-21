###### EXPRESS

_ = require 'underscore'
express = require 'express.io'
partials = require 'express-partials'
util = require 'util'

app = express()
app.http().io()

app.use require("connect-assets")()
app.use express.cookieParser()
app.use express.session secret:'thisismysupersecret'
app.use express.json()
app.use express.urlencoded()

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'

###### Mongo
mongoHostname = process.env.MONGO_URL || 'mongodb://localhost/test'
mongoose = require 'mongoose'
console.log "Connecting to MongoDB: #{mongoHostname}"

mongoose.connect mongoHostname
db = mongoose.connection
db.on "error", console.error.bind(console, "connection error:")
db.once "open", callback = ->
  console.log 'connected to mongodb'

###### MODELS
Message = require './models/message'
User = require './models/user'

###### TWILIO
Twilio = require('twilio')
twilio = Twilio process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN

###### ROUTES
app.get '/seed', (req, res) ->
  userDatas = [{
      phone_number: '16155197142'
      password: '1234'
    },
    {
      phone_number: '12069638669'
      password: '1234'
    }]

  for userData in userDatas
    user = new User userData
    user.save (err, user) ->
      if err
        console.error err
      else
        console.log 'seeded database with user: ' + user
  res.send 200

app.get '/calls/make', (req, res) ->
  #TODO: use environment variable for absolute url
  #TODO: use automatic from number
  call =
    to: "+16155197142"
    from: "+16159135926"
    url: "http://3ada188b.ngrok.com/messages"

  twilio.makeCall call, (err, data) ->
    if err
      console.log err
    else
      console.log data
  res.send 200

#TODO: create media upload route

app.post '/messages/new', (req, res) ->
  #TODO: authenticate & validate user
  #TODO: deliver_at converts epoch to timestamp
  #TODO: validate deliver_at time is in the future
  messageParams = _.pick req.body, 'deliver_at', 'user_id', 'media_url'
  message = new Message messageParams
  message.save (err, message) ->
    if err
      console.error err
    else
      console.log 'created: ' + message
  res.send 200

app.post '/messages', (req, res) ->
  resp = new Twilio.TwimlResponse()
  resp.play 'http://3ada188b.ngrok.com/fixtures/second_call.mp3'
  res.header('Content-Type','text/xml').send resp.toString()

######

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port
