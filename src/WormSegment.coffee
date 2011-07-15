class WormSegment extends jsts.geom.LineSegment
  # TODO: should not introduce start/stop members
  constructor: (@start, @stop, @hole) ->
    super(@start, @stop)

