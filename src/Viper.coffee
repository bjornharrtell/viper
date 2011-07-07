class Viper
    constructor: (canvasgameid, canvastextid) ->
        @version = "0.1"
        @worms = []     

        @canvas = document.getElementById canvasgameid
        @context = @canvas.getContext '2d'
        @canvastext = document.getElementById canvastextid
        @contexttext = @canvastext.getContext '2d'

        worm = new Worm(new Point(0.2, 0.2), 0.4)
        @worms.push(worm)

        d = new Date()
        now = d.getTime()
        @lastTime = now + 100

        @canvastext.width = 500
        @canvastext.height = 15
        @canvas.width = 500
        @canvas.height = 500

        @context.fillStyle = "rgb(0,0,0)"
        @context.fillRect(0, 0, @canvas.width, @canvas.height)
        @context.fillStyle = "rgb(255,0,0)"

        @contexttext.fillStyle    = '#000'
        @contexttext.font         = '10px courier'
        @contexttext.textBaseline = 'top'
        @contexttext.fillText("Viper 0.1", 0, 0)

        document['onkeydown'] = (e) => @onKeyDown(e)
        document['onkeyup'] = (e) => @onKeyUp(e)
        setInterval((=> @timestep()), 50)

    timestep: ->
        d = new Date()

        now = d.getTime()

        if @lastTime > now
            return false

        elapsed = now - @lastTime

        crawl = (worm) =>
            if worm.alive
                worm.move elapsed
                worm.draw @context
                @collisionTest worm

        crawl worm for worm in @worms

        @contexttext.fillStyle = "rgb(255,255,255)"
        @contexttext.fillRect 0, 0, @canvastext.width, @canvastext.height
        @contexttext.fillStyle = '#000'
        @contexttext.font = '10px courier'
        @contexttext.fillText("Viper " + @version + " - Score: " + worm.score, 2, 2)

        @lastTime = now

        return true

    collisionTest: (worm) ->
        test = (otherWorm) ->
            result = otherWorm.collisionTest worm.segments[worm.segments.length-1]
            
            if result is 2
                worm.alive = false
            else if result is 1 
                worm.score += 1            

        test worm for worm in @worms

    onKeyDown: (e) ->
        if e.keyCode is 37
            @worms[0].torque = -0.002    
        else if e.keyCode is 39
            @worms[0].torque = 0.002

    onKeyUp: (e) ->
        if e.keyCode is 37 or e.keyCode is 39
            @worms[0].torque = 0

new Viper("canvasgame","canvastext")

