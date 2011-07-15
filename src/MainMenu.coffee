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
        @viper.initgame()
      else if @currentindex == 1
        @viper.join()
      else if @currentindex == 2
        @viper.create()

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

