class Worm
  constructor: (@position, @direction) ->
    @alive = true
    @score = 0
    @velocity = 0.0001
    @torque = 0
    @distance = 0
    @color = 'white'
    @holeDistance = 0
    @hole = false
    @holes = 0
    @segments = []

    @wormSegmentCache = []
    @lineSegmentIndex = new jsts.simplify.LineSegmentIndex()
  
  move: (time) ->
    @lastPosition = @position.clone()

    wallCollision = true
    x = 0
    y = 0
    distance = 0

    while wallCollision
      # calc new potential position
      @direction += @torque * time
      distance = @velocity * time
      x = @position.x + distance * Math.cos @direction
      y = @position.y + distance * Math.sin @direction

      # find wall collisions and if true reflect direction and redo the move
      if x < 0 or x > 1
        @direction = Math.PI - @direction
        wallCollision = true
        break
      
      if y < 0 or y > 1
        @direction = -@direction
        wallCollision = true
        break

      wallCollision = false

    # valid move is determined so grow the worm..
    @position.x = x
    @position.y = y

    segment = new WormSegment @lastPosition.clone(), @position.clone(), @recordHole()
    @segments.push segment

    if @wormSegmentCache[1] then @wormSegmentCache[2] = @wormSegmentCache[1]
    if @wormSegmentCache[0] then @wormSegmentCache[1] = @wormSegmentCache[0]

    @wormSegmentCache[0] = segment

    if @wormSegmentCache[2] then @lineSegmentIndex.add @wormSegmentCache[2]

    # increase speed
    @distance += distance
    @velocity += 0.0000002
    
    return move =
      x: @position.x
      y: @position.y
      hole: @hole
      wallCollision: wallCollision

  collisionTest: (line) ->
    if @segments.length < 3 then return 0

    intersectingLineSegments = @lineSegmentIndex.query(line);

    for segment in intersectingLineSegments
      rli = new jsts.algorithm.RobustLineIntersector()
      rli.computeIntersection line.p0, line.p1, segment.p0, segment.p1
      if rli.result > 0 and segment.hole then return 1
      if rli.result > 0 and not segment.hole then return 2
    
    return 0
    
  recordHole: ->
    holeInterval = 0.3
    # calc hole length to make it longer as the velocity increases
    holeLength = holeInterval / (14 * (1 - ((@velocity - 0.00005) * 2500)))

    if @distance > @holeDistance + holeInterval and @hole is false
      @hole = true
      @holes++

    if @distance > @holeDistance + holeInterval + holeLength and @hole is true
      @hole = false
      @holeDistance = @distance

    return @hole
  
  draw: (context, color, holeColor) ->
    if @segments.length is 0
      return

    width = context.canvas.width
    height = context.canvas.height
    
    if not color? then color = @color

    context.save()
    segment = @segments[@segments.length-1]
    context.beginPath()
    context.moveTo segment.start.x * width, segment.start.y * height
    context.lineTo segment.stop.x * width, segment.stop.y * height
    context.lineWidth = if segment.hole then 0.3 else 1.5
    context.strokeStyle = color
    context.shadowColor = color
    context.shadowBlur = 9
    context.stroke()
    context.restore()

