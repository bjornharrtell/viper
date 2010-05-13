if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };
}

viper = {
	lastTime: null,
	worms: [],
	canvas: null,
	start: function(id) {
		this.canvas = document.getElementById(id).getContext('2d');	

		var worm = Object.create(viper.worm);
		worm.position = {x: 0.2, y: 0.2};
		worm.direction = 0.4;
		this.worms.push(worm);

		var d = new Date();
		var now = d.getTime();
		this.lastTime = now + 100;

		var that = this;
		var callback = function() {
			if (!that.updatePhysics()) return;

			for (var wormkey in that.worms) {
				var worm = that.worms[wormkey];
				worm.draw(that.canvas);
			}	
		}

		setInterval(callback, 50);
	},
	updatePhysics: function() {
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

