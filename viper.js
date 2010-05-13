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
		worm.position = {x: 0.2, y: 0.2};
		worm.direction = 0.4;
		this.worms.push(worm);

		var d = new Date();
		var now = d.getTime();
		this.lastTime = now + 100;

		// need to get this in a closure for the callback
		var that = this;
		var callback = function() {
			if (!that.timestep()) return;

			for (var wormkey in that.worms) {
				var worm = that.worms[wormkey];
				worm.draw();
			}	
		}

		this.context.fillStyle = "rgb(0,0,0)";
		this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);

		setInterval(callback, 50);
	},
	timestep: function() {
		var d = new Date();

		var now = d.getTime();

		if (this.lastTime > now) return false;

		var elapsed = now - this.lastTime;

		for (var wormkey in this.worms) {
			var worm = this.worms[wormkey];
			worm.move(elapsed);
		}

		this.lastTime = now;

		return true;
	}
};

