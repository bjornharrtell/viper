class MainMenu
  constructor: (@viper) ->
    @menuitems = [$('#startsingle'), $('#joinmulti'), $('#createmulti')]
    @currentindex = 0

    @menuitems[@currentindex].animate
      'color': '#ffffff'

    $(document).bind 'keydown', @keydown

  keydown: (e) =>
    if e.keyCode == 40
      @move true
    if e.keyCode == 38
      @move false
    if e.keyCode == 13
      if @currentindex == 0
        @destroy()
        @viper.init()
      else if @currentindex == 1
        @join()
      else if @currentindex == 2
        @create()

  destroy: ->
    $('#menu').fadeOut()
    $(document).unbind 'keydown', @keydown

  move: (down) ->
    if down and @currentindex is 2 
      return
    else if not down and @currentindex is 0
      return
    
    menuitem = @menuitems[@currentindex]
    menuitem.stop()
    menuitem.animate
      'color': '#888888'
    if down then @currentindex++ else @currentindex--
    menuitem = @menuitems[@currentindex]
    menuitem.stop()
    menuitem.animate
      'color': '#ffffff'
      
  join: ->
    $.ajax
      url: '/games/random'
      success: (sessionID) =>
        $.ajax
          url: "/games/#{sessionID}"
          type: 'POST'
          success: (response) =>
            socket = io.connect()
            socket.emit 'join', 
              hostId: sessionID
              opponentId: @viper.sessionID
   
  create: ->
    $.ajax
      url: '/games'
      type: 'POST'
      success: (response) =>
        socket = io.connect()
        socket.emit 'waiting', @viper.sessionID

