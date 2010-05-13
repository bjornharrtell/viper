viper.worm = {
	alive: true,
	score: 0,
	position: Object.create(viper.point),
	lastPosition: Object.create(viper.point),
	velocity: 0.00005,
	torque: 0.0001,
	direction: 0,
	distance: 0,
	holeDistance: 0,
	hole: false,
	holes: 0,
	segments: [],
	move: function(time) {
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
			if ((x < 0.0) || (x > 1.0)) {
				this.direction = Math.PI - this.direction;
				wallCollision = true;
				break;
			}
			if ((y < 0.0) || (y > 0.95)) {
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
		segment.start = this.lastPosition; 
		segment.stop = this.position;
		this.recordHole();
		this.segments.push(segment);

		// increase speed
		this.distance += distance;
		this.velocity += 0.00000006;
	},
	recordHole: function() {
		var holeInterval = 0.3;
		// calc hole length to make it longer as the velocity increases
		var holeLength = holeInterval / (14.0 * (1.0 - ((this.velocity - 0.00005) * 2500.0)));

		if ((this.distance > (this.holeDistance + holeInterval)) && (this.hole == false)) {
			this.hole = true;
			this.holes++;
		}

		if ((this.distance > (this.holeDistance + holeInterval + holeLength)) && (this.hole == true)) {
			this.hole = false;
			this.holeDistance = this.distance;
		}

		return this.hole;
	},
	draw: function(canvas) {
		var width = 200;
		var height = 200;


		canvas.fillStyle = "rgb(255,255,255)";
		canvas.fillRect(0, 0, 200, 200);

        	canvas.moveTo(this.lastPosition.x * width, this.lastPosition.y * height);
        	canvas.lineTo(this.position.x * width, this.position.y * height);
        	canvas.strokeStyle = "#000";
		canvas.stroke();
	}
}
