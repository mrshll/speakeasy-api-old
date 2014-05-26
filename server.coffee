###### EXPRESS
_ = require 'underscore'
express = require 'express.io'
multer = require 'multer'
util = require 'util'
moment = require 'moment'

app = express()
app.http().io()

app.use require("connect-assets")()
app.use express.cookieParser()
app.use express.session secret:'thisismysupersecret'
app.use express.urlencoded()
app.use express.json()
app.use express.urlencoded()

#TODO maybe use limits and rename options (https://github.com/expressjs/multer)
app.use multer dest: './uploads/'

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'

ROOT_URL = process.env.ROOT_URL || 'http://localhost:7076'

###### MODELS
mongoose = require './db'
Message = require './models/message'
User = require './models/user'

###### TWILIO
Twilio = require 'twilio'
twilio = Twilio process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN

###### ROUTES
helpers = require './helpers'

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
        helpers.debug 'seeded database with user: ' + user
  res.send 200

app.get '/calls/make', (req, res) ->
  #TODO: use automatic from number
  call =
    to: "+16155197142"
    from: "+16159135926"
    url: "#{ ROOT_URL }/twilio/callback"

  twilio.makeCall call, (err, data) ->
    if err
      helpers.debug err
    else
      helpers.debug data
  res.send 200

app.post '/media', (req, res) ->
  #TODO: process & immediately delete file from server
  return res.send 422 unless Object.keys(req.files).length is 1
  for key, file of req.files
    # we just want the first file, so we immediately return
    helpers.debug "File uploaded to #{ file.path }"
    return res.json
      media_uri: "#{ ROOT_URL}/#{ file.path }"

# we have to be non-restful because twilio is posting when we expect it to be
# a GET
app.post '/messages', (req, res) ->
  #TODO: authenticate & validate user
  deliver_at = helpers.calculateFutureDelivery req.body.delivery
  messageParams =
    deliver_at: deliver_at._d
    media_uri: req.body.media_uri

  message = new Message messageParams
  message.save (err, message) ->
    if err
      console.error err
      res.send 500
    else
      helpers.debug 'created: ' + message
      res.send 201

app.post '/twilio/callback', (req, res) ->
  resp = new Twilio.TwimlResponse()
  resp.play "#{ ROOT_URL }/fixtures/second_call.mp3"
  res.header('Content-Type','text/xml').send resp.toString()

######

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port

module.exports = app
