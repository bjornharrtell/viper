class Viper
  constructor: ->
    @version = "0.1"
    @canvas = $('#canvas')
    @context = @canvas.get(0).getContext '2d'
    @score = $('#score')
    @urls = {}
    @worms = []
    
    @sounds =
      background: new Audio("background.ogg")
      bounce: new Audio("bounce.ogg")
      doh: [new Audio("doh1.ogg"), 
        new Audio("doh2.ogg"),
        new Audio("doh3.ogg"),
        new Audio("doh4.ogg"),
        new Audio("doh5.ogg"),
        new Audio("doh6.ogg")]
      gameover: new Audio("gameover.ogg")
      laugh: new Audio("laugh.ogg")
      load: new Audio("load.ogg")
      start: new Audio("start.ogg")
      thread: new Audio("thread.ogg")
      wohoo: new Audio("wohoo.ogg")

    $('#version').text @version
  
    # get root resource
    $.ajax
      url: "/"
      success: @initmenu

  initmenu: (response) =>
    @urls.games = response.games
    @urls.status = response.status
    @sessionID = response.sessionID
    
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
    @gameID = response.gameID
    @socket = io.connect()
    
    @socket.on 'start', @onStart
    @socket.on 'move', @onMove
    
    @socket.emit 'join',
      sessionID: @sessionID
      gameID: @gameID
          
  onMove: (data) =>
    x = data.x
    y = data.y
    hole = data.hole
    
    #console.log "Move recieved x: #{x} y: #{y} hole: #{hole}"

    if @worms.length==1
      worm = new Worm new jsts.geom.Coordinate(x, y), 0
      @worms.push worm
    else
      worm = @worms[1]
      worm.lastPosition = worm.position.clone()
      worm.position = new jsts.geom.Coordinate(x, y)
      segment = new WormSegment worm.lastPosition, worm.position, hole
      worm.segments.push segment
      worm.lineSegmentIndex.add segment
      worm.draw @context, "rgb(155,155,155)", "rgb(25,25,25)"

  onStart: =>
    @mainMenu.destroy()
    @score.fadeIn()

    $(document).keydown (e) => @onKeyDown e
    $(document).keyup (e) => @onKeyUp e
    
    @sounds.start.play()

    setTimeout (=> @startgame()), 500

  startgame: ->
    @sounds.wohoo.play()
    x = (Math.random() * 0.6) + 0.2;
    y = (Math.random() * 0.6) + 0.2;
    direction = (Math.random() - 0.5) * 2.0 * Math.PI;
    worm = new Worm new jsts.geom.Coordinate(x, y), direction
    @worms.push worm

    now = new Date().getTime()
    @lastTime = now + 100
    
    # TODO: optimize with requestAnimationFrame
    setInterval (=> @timestep()), 50

  timestep: ->
    now = new Date().getTime()

    if @lastTime > now then return false

    @elapsed = now - @lastTime

    #@crawl @worms[0]
    @crawl worm for worm in @worms

    @score.text("Score: #{worm.score}")

    @lastTime = now

    return true

  crawl: (worm) ->
    # refactor preliminary mp test code
    if worm != @worms[0] then return
    
    if worm.alive
      move = worm.move @elapsed
      
      #report move to socket
      if @socket
        @socket.emit 'move', 
          sessionID: @sessionID
          gameID: @gameID
          x: move.x
          y: move.y
          hole: move.hole
            
      if move.wallCollision then @sounds.bounce.play()
      worm.draw @context
      @collisionTest worm

  collisionTest: (worm) ->
    test = (otherWorm) =>
      result = otherWorm.collisionTest worm.segments[worm.segments.length-1]
      
      if result is 2
        worm.alive = false
        @sounds.doh[Math.floor(Math.random()*7)].play()
        @sounds.gameover.play()
      else if result is 1 
        worm.score += 1
        @sounds.thread.play()

    test otherWorm for otherWorm in @worms

  onKeyDown: (e) ->
    if e.keyCode is 37
      @worms[0].torque = -0.002  
    else if e.keyCode is 39
      @worms[0].torque = 0.002

  onKeyUp: (e) ->
    if e.keyCode is 37 or e.keyCode is 39
      @worms[0].torque = 0

new Viper()

