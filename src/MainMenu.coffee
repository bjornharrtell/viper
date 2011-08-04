class MainMenu
  constructor: (@viper) ->
    @startsingle = $('#startsingle')
    @joinmulti = $('#joinmulti')
    @createmulti = $('#createmulti')
    @menuitems = [@startsingle, @joinmulti, @createmulti]
    @currentindex = 0

    @menuitems[@currentindex].animate
      'color': '#ffffff'

    $(document).bind 'keydown', @keydown
    @startsingle.bind 'click', @start
    @joinmulti.bind 'click', @join
    @createmulti.bind 'click', @create
    
    $('#menu').fadeIn()

  start: =>
    @destroy()
    @viper.startgame()
    
  join: =>
    @viper.join()

  create: =>
    @viper.create()

  keydown: (e) =>
    if e.keyCode is 40
      @move true
    if e.keyCode is 38
      @move false
    if e.keyCode is 13
      if @currentindex is 0
        @start()
      else if @currentindex is 1
        @join()
      else if @currentindex is 2
        @create()

  destroy: ->
    for menuitem in @menuitems
      menuitem.stop()
      menuitem.css 'color', '#888888'
    $('#menu').fadeOut()
    
    $(document).unbind 'keydown', @keydown
    @startsingle.unbind 'click', @start
    @joinmulti.unbind 'click', @join
    @createmulti.unbind 'click', @create

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

