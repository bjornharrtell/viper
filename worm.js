viper.worm = {
	alive: true,
	score: 0,
	position: null,
	lastPosition: null,
	velocity: 0.00005,
	torque: 0,
	direction: 0,
	distance: 0,
	color: "rgb(255,255,255)",
	holeDistance: 0,
	hole: false,
	holes: 0,
	holeColor: "rgb(50,50,50)",
	segments: [],
	move: function(time) {
		if (this.lastPosition === null) {
			this.lastPosition = Object.create(viper.point);
		}

		this.lastPosition.copyFrom(this.position);

		this.lastPosition.x = this.position.x;
		this.lastPosition.y = this.position.y;

		// precalc next move
		var wallCollision = true;
		var x = 0, y = 0, distance = 0;
		while (wallCollision) {
			// calc new potential position
			this.direction += this.torque * time;
			var distance = this.velocity * time;
			x = this.position.x + distance * Math.cos(this.direction);
			y = this.position.y + distance * Math.sin(this.direction);

			// find wall collisions and if true reflect direction and redo the
			// move
			if (x < 0 || x > 1) {
				this.direction = Math.PI - this.direction;
				wallCollision = true;
				break;
			}
			if (y < 0 || y > 1) {
				this.direction = - this.direction;
				wallCollision = true;
				break;
			}

			wallCollision = false;
		}

		// valid move is determined so grow the worm..
		
		this.position.x = x;
		this.position.y = y;
		var segment = Object.create(viper.wormsegment);
		segment.start = Object.create(viper.point);
		segment.stop = Object.create(viper.point);
		segment.start.copyFrom(this.lastPosition); 
		segment.stop.copyFrom(this.position);
		segment.hole = this.recordHole();
		this.segments.push(segment);

		// increase speed
		this.distance += distance;
		this.velocity += 0.00000006;
	},
	collisionTest: function(line) {
		if (this.segments.length<3) return 0;
		
		for (var i=0; i<this.segments.length-2; i++) {
			var segment = this.segments[i];

			if (line.intersects(segment)) {
				if (segment.hole) {
					return 1;
				}
				else {
					return 2;
				}
			}
		}

		return 0;
	},
	recordHole: function() {
		var holeInterval = 0.3;
		// calc hole length to make it longer as the velocity increases
		var holeLength = holeInterval / (14 * (1 - ((this.velocity - 0.00005) * 2500)));

		if (this.distance > (this.holeDistance + holeInterval) && this.hole == false) {
			this.hole = true;
			this.holes++;
		}

		if (this.distance > (this.holeDistance + holeInterval + holeLength) && this.hole == true) {
			this.hole = false;
			this.holeDistance = this.distance;
		}

		return this.hole;
	},
	draw: function() {
		if (this.segments.length === 0) return;

		var width = viper.canvas.width;
		var height = viper.canvas.height;

		var context = viper.context;

		//for (var key in this.segments) {
			context.save();
			var segment = this.segments[this.segments.length-1];
			context.beginPath();
			context.moveTo(segment.start.x * width, segment.start.y * height);
			context.lineTo(segment.stop.x * width, segment.stop.y * height);
			context.lineWidth = 2;
			context.strokeStyle = !this.hole ? this.color : this.holeColor;
			context.stroke();
			context.restore();
		//}
	}
}
