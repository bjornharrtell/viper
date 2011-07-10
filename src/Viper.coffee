class Viper
    constructor: ->
        @version = "0.1"
        @worms = []     

        @canvas = document.getElementById 'canvas'
        @context = @canvas.getContext '2d'
        @score = document.getElementById 'score'

        @canvas.width = 500
        @canvas.height = 500

        @context.fillStyle = "rgb(0,0,0)"
        @context.fillRect(0, 0, @canvas.width, @canvas.height)
        @context.fillStyle = "rgb(255,0,0)"

        document['onkeydown'] = (e) => @onKeyDown e
        document['onkeyup'] = (e) => @onKeyUp e

        @sounds =
            background: new Audio("background.ogg")
            bounce: new Audio("bounce.ogg")
            doh: [new Audio("doh1.ogg"), 
                new Audio("doh2.ogg"),
                new Audio("doh3.ogg"),
                new Audio("doh4.ogg"),
                new Audio("doh5.ogg"),
                new Audio("doh6.ogg")]
            gameover: new Audio("gameover.ogg")
            laugh: new Audio("laugh.ogg")
            load: new Audio("load.ogg")
            start: new Audio("start.ogg")
            thread: new Audio("thread.ogg")
            wohoo: new Audio("wohoo.ogg")

        @sounds.start.play()
        
        setTimeout (=> @start()), 500

    start: ->
        @sounds.wohoo.play()
        worm = new Worm new Point(0.2, 0.2), 0.4
        @worms.push worm

        now = new Date().getTime()
        @lastTime = now + 100
        # TODO: optimize with requestAnimationFrame
        setInterval (=> @timestep()), 50

    timestep: ->
        now = new Date().getTime()

        if @lastTime > now then return false

        elapsed = now - @lastTime

        crawl = (worm) =>
            if worm.alive
                wallCollision = worm.move elapsed
                if wallCollision then @sounds.bounce.play()
                worm.draw @context
                @collisionTest worm

        crawl worm for worm in @worms

        @score.innerHTML = "Score: #{worm.score}"

        @lastTime = now

        return true

    collisionTest: (worm) ->
        test = (otherWorm) =>
            result = otherWorm.collisionTest worm.segments[worm.segments.length-1]
            
            if result is 2
                worm.alive = false
                @sounds.doh[Math.floor(Math.random()*7)].play()
                @sounds.gameover.play()
            else if result is 1 
                worm.score += 1
                @sounds.thread.play()

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

