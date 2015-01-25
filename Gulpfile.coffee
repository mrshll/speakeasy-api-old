# ------------------------------------------------------------------------------
# Load in modules
# ------------------------------------------------------------------------------
gulp = require 'gulp'
$ = require('gulp-load-plugins')()

fs = require 'fs'
runSequence = require 'run-sequence'
nib = require 'nib'

ENV = process.env.NODE_ENV or 'development'

{config} = require 'rygr-util'
config.initialize 'config/*.json'

# ------------------------------------------------------------------------------
# Custom vars and methods
# ------------------------------------------------------------------------------
alertError = $.notify.onError (error) ->
  console.log 'alert error!'
  message = error?.message or error?.toString() or 'Something went wrong'
  "Error: #{ message }"

# ------------------------------------------------------------------------------
# Directory management
# ------------------------------------------------------------------------------
gulp.task 'clean', ->
  dir = config.client.build.root
  fs.mkdirSync dir unless fs.existsSync dir

  gulp.src("#{ dir }/*", read: false)
    .pipe($.plumber errorHandler: alertError)
    .pipe $.rimraf force: true

# ------------------------------------------------------------------------------
# Copy static assets
# ------------------------------------------------------------------------------
gulp.task 'public', ->
  gulp.src("#{ config.client.src.public }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.root)
    .pipe gulp.dest config.client.build.root

gulp.task 'vendor-css', ->
  stylusFilter = $.filter '**/*.styl'

  gulp.src("#{ config.client.src.vendor }/**/*.css")
    .pipe($.filter ['**/*.styl', '**/*.css'])
    .pipe(stylusFilter)
    .pipe($.stylus
      'cache limit': 1
      set: ['compress']
      use: [nib()]
    )
    .pipe(stylusFilter.restore())
    .pipe($.plumber errorHandler: alertError)
    .pipe($.concat 'vendor.css')
    .pipe($.if (ENV is 'production'), $.minifyCss())
    .pipe(gulp.dest config.client.build.styles)
    .pipe($.size())

gulp.task 'images', ->
  gulp.src("#{ config.client.src.images }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.changed config.client.build.assets)
    .pipe(gulp.dest config.client.build.assets)
    .pipe($.size())

# ------------------------------------------------------------------------------
# Compile assets
# ------------------------------------------------------------------------------
devLocals = {
  messages:[{
    text: 'Lorem ipsum dolor sit amet, minim molestie argumentum est at, pri legere torquatos instructior ex. Vis id odio atomorum oportere, quem modo fabellas sit at, dicat semper est ne. Apeirian detraxit pri eu. No solum accusam has. Ius ne harum mundi clita, eu pro tation audiam.\n\n\n\n\nSed dicit necessitatibus in, id posse nominati eos. Ea vel dictas facilisi adipiscing, verear phaedrum sed ei, omnes oblique sanctus mea ex. Iudico pertinacia constituam cu eos. Te vel fugit libris, libris nemore no pri, graece oportere sea ea. Amet omnium epicuri cum te, sonet dignissim abhorreant pro ea, mei petentium constituam ad. Suscipit gloriatur necessitatibus has et.\n\n test\n\n\n\n\n\n\n\ntest\n\nOn Sat, Jan 24, 2015 at 12:00 AM, Marshall Moutenot <mmoutenot@gmail.com>\nwrote:\n\n> Poop, doods! Couldn\'t motivate myself to run in the morning because of the c00000ld, but shit it was my last chance for an outside long for a few days boo me! Made up for it with a 4 hour climbing/training session in the night. Super good crew, everyone knows one another and cheers as they climb. Nothing like that in fitness that I have experienced. Banged out some late-night before-bed features for Driftt that made the day complete. Work has been placid since we were in \'explore\' mode, but a summer camp compared to where it\'s going. We\'ve honed in on what we want to build and where we want to be and shit is going to *ramp up*.',
    from: 'mmoutenot@gmail.com',
    __v: 0,
  }]
}

gulp.task 'jade', ->
  gulp.src("#{ config.client.src.views }/**/*.jade")
    .pipe($.jade { pretty:true, locals: devLocals })
    .pipe($.preprocess context: ENV: ENV)

    .pipe(gulp.dest config.client.build.views)
    .pipe($.size())

gulp.task 'stylus', ->
  delete require.cache[require.resolve 'gulp-stylus']
  $.stylus = require 'gulp-stylus'

  gulp.src("#{ config.client.src.stylesheets }/main.styl")
    .pipe($.stylus
      'cache limit': 1
      paths: [
        config.client.src.stylesheets
        config.client.build.assets
      ]
      use: [nib()]
      import: ['components/*.styl', 'globals/*.styl']
    )
    .pipe($.autoprefixer
      browsers: ['last 2 versions'],
      cascade: false
    )
    .on 'error', (e) ->
      $.util.log(e.toString())
      this.emit('end')
    .pipe($.if (ENV is 'production'), $.minifyCss())
    .pipe(gulp.dest config.client.build.styles)
    .pipe($.size())

gulp.task 'inline-css', ->
  gulp.src("#{ config.client.build.views}/**/*.html")
    .pipe($.inlineCss())
    .pipe(gulp.dest config.client.build.emails)
    .pipe($.size())

# ------------------------------------------------------------------------------
# Server
# ------------------------------------------------------------------------------
gulp.task 'email-dev-server', ->
  nodemon = require 'nodemon'

  nodemon
    script: config.emailDevServer.main
    watch: config.emailDevServer.root
    ext: 'js coffee json'

  nodemon
    .on('start', -> console.log 'Server has started')
    .on('quit', -> console.log 'Server has quit')
    .on('restart', (files) -> console.log 'Server restarted due to: ', files)


# ------------------------------------------------------------------------------
# Build
# ------------------------------------------------------------------------------
gulp.task 'build', (cb) ->
  sequence = [
    'clean'
    ['vendor-css', 'jade', 'images', 'public', 'stylus']
    'inline-css'
    cb
  ]
  runSequence sequence...

gulp.task 'set-production', (cb) ->
  ENV = 'production'
  cb()

gulp.task 'production', (cb) ->
  sequence = [
    'set-production'
    'build'
    'deploy-assets'
    cb
  ]

  runSequence sequence...

# ------------------------------------------------------------------------------
# Deploy
# ------------------------------------------------------------------------------
gulp.task 'deploy-assets', ->
  aws =
    key: config.client.deploy.awsKey
    secret: config.client.deploy.awsSecret
    bucket: config.client.deploy.awsBucket
    region: config.client.deploy.awsRegion
  headers = 'Cache-Control': 'max-age=315360000, no-transform, public'
  indexHeaders = 'Cache-Control': 'max-age=10, no-transform, public'

  publisher = $.awspublish.create(aws)

  gulp.src("#{ config.client.build.assets }/**")
    .pipe($.plumber errorHandler: alertError)
    .pipe($.awspublish.gzip())
    .pipe(publisher.publish headers)
    .pipe(publisher.cache())
    .pipe($.awspublish.reporter())

# ------------------------------------------------------------------------------
# Watch
# ------------------------------------------------------------------------------
gulp.task 'watch', (cb) ->
  lr = $.livereload config.livereload.port

  gulp.watch("#{ config.client.build.emails }/**")
    .on 'change', (file) ->
      lr.changed file.path

  gulp.watch "#{ config.client.src.views }/**/*.jade", ['jade']
  gulp.watch "#{ config.client.src.stylesheets }/**/*.styl", ['stylus']
  gulp.watch "#{ config.client.src.images }/**", ['images']
  gulp.watch "#{ config.client.src.public }/**", ['public']

  gulp.watch "#{ config.client.build.styles }/**/*.css", ['inline-css']
  gulp.watch "#{ config.client.build.views }/**/*.html", ['inline-css']

  cb()

# ------------------------------------------------------------------------------
# Default
# ------------------------------------------------------------------------------
gulp.task 'default', ->
  runSequence 'build', ['watch', 'email-dev-server']
