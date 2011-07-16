class MainMenu
  constructor: (@viper) ->
    @menuitems = [$('#startsingle'), $('#joinmulti'), $('#createmulti')]
    @currentindex = 0

    @menuitems[@currentindex].animate
      'color': '#ffffff'

    $(document).bind 'keydown', @keydown
    
    $('#menu').fadeIn()

  keydown: (e) =>
    if e.keyCode is 40
      @move true
    if e.keyCode is 38
      @move false
    if e.keyCode is 13
      if @currentindex is 0
        @destroy()
        @viper.startgame()
      else if @currentindex is 1
        @viper.join()
      else if @currentindex is 2
        @viper.create()

  destroy: ->
    for menuitem in @menuitems
      do (menuitem) ->
        menuitem.stop()
        menuitem.css 'color', '#888888'
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

