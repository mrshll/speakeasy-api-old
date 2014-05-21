###### EXPRESS

express = require 'express.io'
partials = require 'express-partials'
util = require 'util'

app = express()
app.http().io()

app.use require("connect-assets")()
app.use express.cookieParser()
app.use express.session secret:'thisismysupersecret'

app.configure ->
  app.set 'view engine', 'hamlc'
  app.set 'layout', 'layout'

app.use express.static __dirname + '/assets'

###### TWILIO
Twilio = require('twilio')
twilio = Twilio process.env.TWILIO_ACCOUNT_SID process.env.TWILIO_AUTH_TOKEN

###### ROUTES
app.get '/', (req, res) ->
  call =
    to: "+16155197142"
    from: "+16159135926"
    url: "http://3ada188b.ngrok.com/calls"

  twilio.makeCall call, (err, data) ->
    if err
      console.log err
    else
      console.log data

  res.send 200

app.post '/calls', (req, res) ->
  resp = new Twilio.TwimlResponse()
  resp.play 'http://3ada188b.ngrok.com/fixtures/second_call.mp3'
  res.header('Content-Type','text/xml').send resp.toString()

appPort = process.env.PORT or 7076
server = app.listen appPort, ->
  console.log 'Listening on port %d', server.address().port
