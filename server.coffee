_ = require 'underscore'
moment = require 'moment'
async = require 'async'

###### EXPRESS
express = require 'express.io'
multer = require 'multer'
util = require 'util'

app = express()
app.http().io()

app.use require("connect-assets")()
app.use express.cookieParser()
app.use express.session secret:'thisismysupersecret'
app.use express.json()

#TODO maybe use limits and rename options (https://github.com/expressjs/multer)
app.use multer dest: './uploads/'

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'
app.use '/uploads', express.static __dirname + '/uploads'

###### MODELS
mongoose = require './db'
Message = require './models/message'
User = require './models/user'

# Custom middleware to output route in debug mode
app.use (req, res, next) ->
  helpers.debug "#{ req.originalUrl } #{ req.method }"
  next()

# Custom middleware to hydrate request with current user
app.use (req, res, next) ->
  if req.session and req.session.userID
    User.findById req.session.userID, (err, user) ->
      if not err and user
        req.user = user
        next()
      else
        next new Error("Could not restore User from Session.")
  else
    next()

userRequired = (req, res, next) ->
  # TODO: Authenticate
  if req.user then next() else next new Error 'Not Logged In'

###### TWILIO
Twilio = require 'twilio'
twilio = Twilio process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN

app.post '/twilio/callback', (req, res) ->
  messageId = req.query.message_id
  return res.send 422 unless messageId

  Message.findById messageId, (err, message) ->
    console.log message
    if err
      console.log err
      res.send 500
    else
      resp = new Twilio.TwimlResponse()
      resp.play message.media_uri

      message.completed_at = moment()._d
      message.in_progress = false

      message.save (err, message) ->
        res.header('Content-Type','text/xml').send resp.toString()

###### ROUTES
helpers = require './helpers'
helpers.debug 'debug mode enabled'

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

    messageDatas = [{
      deliver_at: moment()._d
      media_uri: 'fixtures/first_call.mp3'
      _user: user._id
    }]

    for messageData in messageDatas
      message = new Message messageData
      message.save (err, message) ->
        if err
          console.error err
        else
          helpers.debug 'seeded database with message: ' + message

  res.send 200

app.get '/user_id', (req, res) ->
  User.findOne {}, (err, user) ->
    res.json user_id: user._id

#TODO: authenticate & validate user
app.post '/messages', (req, res) ->
  params = req.body
  return res.send 422 unless params.delivery_unit and
    params.delivery_magnitude and
    params.user_id and
    Object.keys(req.files).length is 1

  for key, file of req.files
    # we just want the first file, so we immediately return
    helpers.debug "File uploaded to #{ file.path }"
    media_uri = "#{ helpers.ROOT_URL}/#{ file.path }"
    #TODO enqueu the media into a topic for conversion

  deliver_at = helpers.calculateFutureDelivery params.delivery_unit, params.delivery_magnitude
  messageParams =
    deliver_at: deliver_at._d
    media_uri: media_uri
    _user: params.user_id

  message = new Message messageParams
  message.save (err, message) ->
    if err
      console.error err
      res.send 500
    else
      helpers.debug 'created: ' + message
      res.send 201

######

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port

module.exports = app
