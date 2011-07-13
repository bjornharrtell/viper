class WormSegment extends jsts.geom.LineSegment
  constructor: (@start, @stop, @hole) ->
    super(@start, @stop)

