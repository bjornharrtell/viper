// crockford style prototypal inheritance method
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

// namespace and singleton instance of the game
viper = {
	lastTime: null,
	worms: [],
	canvas: null,
	context: null,
	start: function(id) {
		this.canvas = document.getElementById(id);
		this.context = this.canvas.getContext('2d');

		var worm = Object.create(viper.worm);
		worm.position = Object.create(viper.point);
		worm.position.x = 0.2;
		worm.position.y = 0.2;
		worm.direction = 0.4;
		this.worms.push(worm);

		var d = new Date();
		var now = d.getTime();
		this.lastTime = now + 100;

		this.context.fillStyle = "rgb(0,0,0)";
		this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);

		var that = this;
		document['onkeydown'] = function(e) { that.onKeyDown(e); };
		document['onkeyup'] = function(e) { that.onKeyUp(e); };
		setInterval(function() { that.timestep(); }, 50);
	},
	timestep: function() {
		var d = new Date();

		var now = d.getTime();

		if (this.lastTime > now) return false;

		var elapsed = now - this.lastTime;

		for (var wormkey in this.worms) {
			var worm = this.worms[wormkey];

			if (worm.alive) {
				worm.move(elapsed);
				worm.draw();
				this.collisionTest(worm);
			}
		}

		this.lastTime = now;

		return true;
	},
	collisionTest: function(worm) {
		for (var wormkey in this.worms) {
			var otherWorm = this.worms[wormkey];

			var result = otherWorm.collisionTest(worm.segments[worm.segments.length-1]);
			
			if (result == 2) {
				worm.alive = false;
			}
		}
	},
	onKeyDown: function(e) {
		if (e.keyCode == 37) {
			this.worms[0].torque = -0.002;	
		}
		else if (e.keyCode == 39) {
			this.worms[0].torque = 0.002;	
		}
	},
	onKeyUp: function(e) {
		if (e.keyCode == 37 || e.keyCode == 39) {
			this.worms[0].torque = 0;	
		}
	}
};

