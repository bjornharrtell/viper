
viper.line = {
	start: Object.create(viper.point),
	stop: Object.create(viper.point),
	horisontal: true, 
	vertical: true, 
        k: 0,
        m: 0,
        calcConstants: function(line) {
		this.horisontal = false;
		this.vertical = false;

		if (this.stop.y - this.start.y == 0) {
			this.horisontal = true;
			this.k = 0;
			this.m = stop.y;
			return;
		}

		if (this.stop.x - this.start.x == 0) {
			this.vertical = true;
			return;
		}
		
		this.k = (this.stop.y - this.start.y) / (this.stop.x - this.start.x);
		this.m = this.start.y - (this.k * this.start.x);		
	},
	intersects: function(line) {
		this.calcConstants();
		line.calcConstants();

		var x, y;

		if (this.vertical && line.vertical) {
			return false;
		}
		else if (this.vertical) {
			x = this.start.x;
			y = (x * line.k) + line.m;
		}
		else if (line.vertical) {
			x = line.start.x;
			y = (x * this.k) + this.m;
		}
		else if (this.horisontal && line.horisontal)	{
			return false;
		}
		else if (this.horisontal) {	
			y = this.start.y;
			x = (y - line.m) / line.k;
		}
		else {
			x = (this.m-line.m) / (line.k-this.k);
			y = ( (this.k*line.m) - (line.k*this.m) ) / (this.k-line.k);
		}
	
		if ( this.within(x,y) && line.within(x,y) ) {
			return true;
		}
		else {
			return false;
		}
	},
	within: function(x, y) {
		result = false;

		var min, max;

		min = this.start.x;
		max = this.stop.x;

		if (min > max) {
			var tmp = min;
			min = max;
			max = tmp;
		}

		if (x > min && x < max) result = true;

		min = this.start.y;
		max = this.stop.y;

		if (min > max) {
			var tmp = min;
			min = max;
			max = tmp;
		}

		if (y > min && y < max) result = result && true;

		return true;
	}
}

