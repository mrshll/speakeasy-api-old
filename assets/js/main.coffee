socket = io.connect()
socket.emit 'ready'

socket.on 'connectionEvent', (data) ->
  console.log data.status

# EKG
$(document).ready ->
  ctx = ekg.getContext '2d'
  ctx.canvas.width  = window.innerWidth
  ctx.canvas.height = window.innerHeight

  w = ctx.canvas.width
  h = ctx.canvas.height

  px = 0
  ppx = px
  dx = 1

  start_y = h * 0.6
  py = start_y
  ppy = start_y

  # hot flow
  dy = 0
  ddy = 0
  apex = 0

  switched = false
  blipping = false

  scanBarWidth = 20

  ctx.strokeStyle = '#fff'
  ctx.lineWidth = 2

  socket.on "tweetEvent:#{ topic }", (data) ->
    console.log data.text + ' - ' + data.handle
    $('.tweet').text "#{ data.text } - #{ data.handle }"
    if not blipping
      dy = -50
      ddy = -5
      blipping = true
      switched = false

  draw = () ->
    px += dx

    ctx.clearRect px, 0, scanBarWidth, h
    ctx.beginPath()
    ctx.moveTo ppx, ppy
    ctx.lineTo px, py
    ctx.stroke()

    ppx = px
    ppy = py

    if  ppx > w
      px = ppx = -dx

    py += dy
    dy -= ddy

    if py > start_y and ddy isnt 0 and blipping and not switched
      ddy = -ddy
      switched = true
    else if py < start_y and ddy isnt 0 and switched
      ddy = 0
      dy = 0
      switched = false
      blipping = false

    requestAnimationFrame draw

  draw()
