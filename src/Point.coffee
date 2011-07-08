class Point
    constructor: (@x, @y) ->

    distanceTo: (p) ->
        dx = p.x-@x
        dy = p.y-@y
        Math.sqrt(dx*dx + dy*dy)

    clone: ->
        new Point(@x, @y)

