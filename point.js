viper.point = {
	x: null,
	y: null,
	copyFrom: function(point) {
		point.copyTo(this);
	},
	copyTo: function(point) {
		point.x = this.x;
		point.y = this.y;
	}
};

