class Viper
    constructor: ->
        @version = "0.1"
        @worms = []     

        @canvas = document.getElementById 'canvas'
        @context = @canvas.getContext '2d'
        @score = document.getElementById 'score'

        worm = new Worm(new Point(0.2, 0.2), 0.4)
        @worms.push worm

        d = new Date()
        now = d.getTime()
        @lastTime = now + 100

        @canvas.width = 500
        @canvas.height = 500

        @context.fillStyle = "rgb(0,0,0)"
        @context.fillRect(0, 0, @canvas.width, @canvas.height)
        @context.fillStyle = "rgb(255,0,0)"

        document['onkeydown'] = (e) => @onKeyDown e
        document['onkeyup'] = (e) => @onKeyUp e

        # TODO: optimize with requestAnimationFrame
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

        @score.innerHTML = "Score: #{worm.score}"

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

new Viper()

