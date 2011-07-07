class Line
    constructor: (@start, @stop) ->

    calcConstants: ->
        @horisontal = false
        @vertical = false

        if @stop.y - @start.y is 0
            @horisontal = true
            @k = 0
            @m = @stop.y
            return
        if @stop.x - @start.x is 0
            @vertical = true
            return
        else
            @k = (@stop.y - @start.y) / (@stop.x - @start.x)
            @m = @start.y - (@k * @start.x)

    intersects: (line) ->
        @calcConstants();
        line.calcConstants();

        if (@vertical and line.vertical) 
            return false;
        else if (@vertical) 
            x = @start.x;
            y = (x * line.k) + line.m;
        else if (line.vertical) 
            x = line.start.x;
            y = (x * @k) + @m;
        else if (@horisontal and line.horisontal)
            return false;
        else if (@horisontal)   
            y = @start.y;
            x = (y - line.m) / line.k
        else 
            x = (@m-line.m) / (line.k-@k)
            y = ( (@k*line.m) - (line.k*@m) ) / (@k-line.k)
        
        if @within(x,y) and line.within(x,y)
            return true
        else
            return false

    within: (x, y) ->
        result = false

        min = @start.x
        max = @stop.x

        if min > max
            tmp = min
            min = max
            max = tmp

        if x > min and x < max
            result = true

        min = @start.y
        max = @stop.y

        if min > max
            tmp = min
            min = max
            max = tmp

        if y > min and y < max
            result = result and true;

        return result

