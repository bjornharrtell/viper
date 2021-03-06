class Viper
  constructor: ->
    @version = "0.5.8"
    @canvas = $('#canvas')
    @context = @canvas.get(0).getContext '2d'
    @score = $('#score')
    @progress = $('#progress')
    @urls = {}
    @worms = []
    @gamerunning = false
    @isTouch = false
    
    @sounds =
      background: new Audio("snd/background.ogg")
      bounce: new Audio("snd/bounce.ogg")
      doh: [new Audio("snd/doh1.ogg"), 
        new Audio("snd/doh2.ogg"),
        new Audio("snd/doh3.ogg"),
        new Audio("snd/doh4.ogg"),
        new Audio("snd/doh5.ogg"),
        new Audio("snd/doh6.ogg")]
      gameover: new Audio("snd/gameover.ogg")
      laugh: new Audio("snd/laugh.ogg")
      load: new Audio("snd/load.ogg")
      start: new Audio("snd/start.ogg")
      thread: new Audio("snd/thread.ogg")
      wohoo: new Audio("snd/wohoo.ogg")

    $('#version').text @version
  
    # get root resource
    $.ajax
      url: "/"
      success: @init

  init: (response) =>
    @urls.games = response.games
    @urls.status = response.status
    @sessionID = response.sessionID

    @initmenu()

  initmenu: =>
    @progress.fadeOut()
    
    @context.clearRect 0, 0, @canvas.width(), @canvas.height()
  
    @mainMenu = new MainMenu @
  
    # Get server status
    $.ajax
      url: "/#{@urls.status}"
      success: (response) ->
        $('#users').text "Users online: #{response.usersCount}"
        $('#gameswaiting').text "Games waiting for players to join: #{response.gamesWaitingCount}"
        $('#gamesinprogress').text "Games in progress: #{response.gamesStartedCount}"
  
  create: ->
    $.ajax
      url: "/#{@urls.games}"
      type: 'POST'
      success: @joingame

  join: ->
    $.ajax
      url: "/#{@urls.games}/random"
      success: @joingame
          
  joingame: (response) =>
    if not response.success
      @mainMenu.destroy()
      @progress.text 'No game available, try creating one.'
      @progress.fadeIn()
      setTimeout @initmenu, 3000
      return
  
    @gameID = response.gameID
    if not @socket?
      @socket = io.connect()
    
      @socket.on 'start', @onStart
      @socket.on 'move', @onMove
      @socket.on 'gameover', @onGameover
    
    @socket.emit 'join',
      sessionID: @sessionID
      gameID: @gameID
    
    @mainMenu.destroy()
    @progress.text 'Game joined, now waiting for an opponent to join...'
    @progress.fadeIn()
          
  onMove: (data) =>
    x = data.x
    y = data.y
    hole = data.hole

    if @worms.length is 1
      worm = new Worm new jsts.geom.Coordinate(x, y), 0
      @worms.push worm
    else
      worm = @worms[1]
      worm.lastPosition = worm.position.clone()
      worm.position = new jsts.geom.Coordinate(x, y)
      segment = new WormSegment worm.lastPosition, worm.position, hole
      worm.segments.push segment
      worm.lineSegmentIndex.add segment
      worm.draw @context, 'red'

  onStart: =>
    @progress.fadeOut()
    setTimeout @startgame, 500
    
  onGameover: (data) =>
    clearInterval @intervalID
    @gamerunning = false
    $(document).unbind 'keydown', @onKeydown
    $(document).unbind 'keyup', @onKeup
    $(document).unbind 'mousedown', @onMousedown
    $(document).unbind 'mouseup', @onMouseup
    $(document).unbind 'touchstart', @onTouchstart
    $(document).unbind 'touchend', @onTouchend
    @worms = []
  
    if data is 0
      @progress.text 'Draw!'
    else if data is 1
      @progress.text 'You won!' 
    else if data is 2
      @progress.text 'You lost!'
    else if data is 3
      @progress.text 'Opponent disconnected!'
 
    @progress.fadeIn()
    
    @sounds.gameover.play()
    
    setTimeout @initmenu, 3000

  startgame: =>
    @gamerunning = true
  
    @context.clearRect 0, 0, @canvas.width(), @canvas.height()
  
    $(document).bind 'keydown', @onKeydown
    $(document).bind 'keyup', @onKeyup
    $(document).bind 'mousedown', @onMousedown
    $(document).bind 'mouseup', @onMouseup
    $(document).bind 'touchstart', @onTouchstart
    $(document).bind 'touchend', @onTouchend
    @score.fadeIn()
    @sounds.start.play()
    @sounds.wohoo.play()
    x = Math.random() * 0.6 + 0.2;
    y = Math.random() * 0.6 + 0.2;
    direction = (Math.random() - 0.5) * 2.0 * Math.PI;
    worm = new Worm new jsts.geom.Coordinate(x, y), direction
    @worms.push worm

    now = new Date().getTime()
    @lastTime = now + 100
    
    # TODO: optimize with requestAnimationFrame
    @intervalID = setInterval @timestep, 50

  timestep: =>
    now = new Date().getTime()

    if @lastTime > now then return false

    @elapsed = now - @lastTime

    worm = @worms[0]
    
    if worm.alive
      move = worm.move @elapsed
            
      if move.wallCollision then @sounds.bounce.play()
      worm.draw @context
      @collisionTest worm
      
      # report move to server which will send it to other player(s)
      if @socket
        @socket.emit 'move', 
          sessionID: @sessionID
          gameID: @gameID
          x: move.x
          y: move.y
          hole: move.hole
          alive: worm.alive
          score: worm.score
    
    @score.text "Score: #{worm.score}"

    @lastTime = now

    return true

  collisionTest: (worm) ->
    for otherWorm in @worms
      result = otherWorm.collisionTest worm.segments[worm.segments.length-1]
      
      if result is 2
        worm.alive = false
        dohIndex = Math.floor Math.random() * 6
        @sounds.doh[dohIndex].play()
        if @worms.length is 1 then @onGameover()
      else if result is 1 
        worm.score += 1
        @sounds.thread.play()

  onKeydown: (e) =>
    e.preventDefault()
    if e.keyCode is 37
      @worms[0].torque = -0.002
    else if e.keyCode is 39
      @worms[0].torque = 0.002

  onKeyup: (e) =>
    e.preventDefault();
    if e.keyCode is 37 or e.keyCode is 39
      @worms[0].torque = 0
      
  onMousedown: (e) =>
    e.preventDefault()
    
    if e.clientX < $(document).width()/2
      @worms[0].torque = -0.002
    else
      @worms[0].torque = 0.002
    
  onMouseup: (e) =>
    e.preventDefault()

    @worms[0].torque = 0
    
  onTouchstart: (e) =>
    e.preventDefault()
  
    if not @isTouch
      $(document).unbind 'mousedown', @onMousedown
      $(document).unbind 'mouseup', @onMouseup
      @isTouch = true
      
    if e.originalEvent.touches.length isnt 1
      return false
    
    touch = e.originalEvent.touches[0]
    
    if touch.pageX < $(document).width()/2
      @worms[0].torque = -0.002
    else
      @worms[0].torque = 0.002
    
  onTouchend: (e) =>
    e.preventDefault()

    @worms[0].torque = 0
    
new Viper()

