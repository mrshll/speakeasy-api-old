{file, config} = require 'rygr-util'
path = require 'path'

express = require 'express'
exphbs  = require 'express-handlebars'

_ = require 'underscore'

# Load in configs
paths = ["#{path.join(__dirname, '..', 'config')}/*.json", 'config/*.json']
config.initialize paths

# Call initializers
require('./initializers/main')()

# Setup Express app
app = express()

# Setup directories
dirs =
  base: __dirname
  public: path.resolve __dirname, '..', config.client.build.emails
  assets: path.resolve __dirname, '..', config.client.build.assets

app.set 'dirs', dirs

# Handlebars Preview
# tell view engine that all html files should be given handlebars treatment
handleBarsOpts =
  layoutsDir: dirs.public
  extname: '.html'
app.engine '.html', exphbs(handleBarsOpts)
app.set 'view engine', '.html'
app.set 'views', dirs.public
app.set 'factoryDataDir', config.emailDevServer.factoryDataDir

# Set middleware
require('./middleware/main') app

# Start listening
server = app.listen config.emailDevServer.port, ->
  console.log "Server listening on port #{ config.emailDevServer.port }"

# Make sure to shut down the server if the process is terminated
process.on 'SIGTERM', server.close

# Return the server
module.export = server
