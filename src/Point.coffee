class Point
    constructor: (@x, @y) ->

    clone: ->
        new Point(@x, @y)

