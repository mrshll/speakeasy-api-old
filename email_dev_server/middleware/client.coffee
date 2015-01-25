_ = require 'underscore'
fs = require 'fs'

module.exports = (app) ->
  (req, res, next) ->
    if !req.accepts('html') or _(req.path).startsWith '/assets/'
      next()
      return

    # pull view name 'example' from path '/example.html'
    pathParts = req.path.split '/'
    view = pathParts[pathParts.length - 1].split('.')[0]

    res.render view
