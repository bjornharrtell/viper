(function() {
  var Line, Point, Viper, Worm, WormSegment;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  }, __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  Point = (function() {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }
    Point.prototype.distanceTo = function(p) {
      var dx, dy;
      dx = p.x - this.x;
      dy = p.y - this.y;
      return Math.sqrt(dx * dx + dy * dy);
    };
    Point.prototype.clone = function() {
      return new Point(this.x, this.y);
    };
    return Point;
  })();
  Line = (function() {
    function Line(start, stop) {
      this.start = start;
      this.stop = stop;
    }
    Line.prototype.calcConstants = function() {
      this.horisontal = false;
      this.vertical = false;
      if (this.stop.y - this.start.y === 0) {
        this.horisontal = true;
        this.k = 0;
        this.m = this.stop.y;
        return;
      }
      if (this.stop.x - this.start.x === 0) {
        this.vertical = true;
      } else {
        this.k = (this.stop.y - this.start.y) / (this.stop.x - this.start.x);
        return this.m = this.start.y - (this.k * this.start.x);
      }
    };
    Line.prototype.intersects = function(line) {
      var x, y;
      this.calcConstants();
      line.calcConstants();
      if (this.vertical && line.vertical) {
        return false;
      } else if (this.vertical) {
        x = this.start.x;
        y = (x * line.k) + line.m;
      } else if (line.vertical) {
        x = line.start.x;
        y = (x * this.k) + this.m;
      } else if (this.horisontal && line.horisontal) {
        return false;
      } else if (this.horisontal) {
        y = this.start.y;
        x = (y - line.m) / line.k;
      } else {
        x = (this.m - line.m) / (line.k - this.k);
        y = ((this.k * line.m) - (line.k * this.m)) / (this.k - line.k);
      }
      if (this.within(x, y) && line.within(x, y)) {
        return true;
      } else {
        return false;
      }
    };
    Line.prototype.within = function(x, y) {
      var max, min, result, tmp;
      result = false;
      min = this.start.x;
      max = this.stop.x;
      if (min > max) {
        tmp = min;
        min = max;
        max = tmp;
      }
      if (x > min && x < max) {
        result = true;
      }
      min = this.start.y;
      max = this.stop.y;
      if (min > max) {
        tmp = min;
        min = max;
        max = tmp;
      }
      if (y > min && y < max) {
        result = result && true;
      }
      return result;
    };
    return Line;
  })();
  WormSegment = (function() {
    __extends(WormSegment, Line);
    function WormSegment(start, stop, hole) {
      this.start = start;
      this.stop = stop;
      this.hole = hole;
      WormSegment.__super__.constructor.call(this, this.start, this.stop);
    }
    return WormSegment;
  })();
  Worm = (function() {
    function Worm(position, direction) {
      this.position = position;
      this.direction = direction;
      this.alive = true;
      this.score = 0;
      this.velocity = 0.0001;
      this.torque = 0;
      this.distance = 0;
      this.color = "rgb(255,255,255)";
      this.holeDistance = 0;
      this.hole = false;
      this.holes = 0;
      this.holeColor = "rgb(50,50,50)";
      this.segments = [];
    }
    Worm.prototype.move = function(time) {
      var distance, segment, wallCollision, x, y;
      this.lastPosition = this.position.clone();
      wallCollision = true;
      x = 0;
      y = 0;
      distance = 0;
      while (wallCollision) {
        this.direction += this.torque * time;
        distance = this.velocity * time;
        x = this.position.x + distance * Math.cos(this.direction);
        y = this.position.y + distance * Math.sin(this.direction);
        if (x < 0 || x > 1) {
          this.direction = Math.PI - this.direction;
          wallCollision = true;
          break;
        }
        if (y < 0 || y > 1) {
          this.direction = -this.direction;
          wallCollision = true;
          break;
        }
        wallCollision = false;
      }
      this.position.x = x;
      this.position.y = y;
      segment = new WormSegment(this.lastPosition.clone(), this.position.clone(), this.recordHole());
      this.segments.push(segment);
      this.distance += distance;
      return this.velocity += 0.0000002;
    };
    Worm.prototype.collisionTest = function(line) {
      var count, segment;
      if (this.segments.length < 3) {
        return 0;
      }
      count = 0;
      while (count < this.segments.length - 2) {
        segment = this.segments[count];
        if (line.intersects(segment)) {
          if (segment.hole) {
            return 1;
          } else {
            return 2;
          }
        }
        count++;
      }
      return 0;
    };
    Worm.prototype.recordHole = function() {
      var holeInterval, holeLength;
      holeInterval = 0.3;
      holeLength = holeInterval / (14 * (1 - ((this.velocity - 0.00005) * 2500)));
      if (this.distance > this.holeDistance + holeInterval && this.hole === false) {
        this.hole = true;
        this.holes++;
      }
      if (this.distance > this.holeDistance + holeInterval + holeLength && this.hole === true) {
        this.hole = false;
        this.holeDistance = this.distance;
      }
      return this.hole;
    };
    Worm.prototype.draw = function(context) {
      var height, segment, width;
      if (this.segments.length === 0) {
        return;
      }
      width = context.canvas.width;
      height = context.canvas.height;
      context.save();
      segment = this.segments[this.segments.length - 1];
      context.beginPath();
      context.moveTo(segment.start.x * width, segment.start.y * height);
      context.lineTo(segment.stop.x * width, segment.stop.y * height);
      context.lineWidth = 2;
      context.strokeStyle = this.hole ? this.holeColor : this.color;
      context.stroke();
      return context.restore();
    };
    return Worm;
  })();
  Viper = (function() {
    function Viper() {
      var d, now, worm;
      this.version = "0.1";
      this.worms = [];
      this.canvas = document.getElementById('canvas');
      this.context = this.canvas.getContext('2d');
      this.score = document.getElementById('score');
      worm = new Worm(new Point(0.2, 0.2), 0.4);
      this.worms.push(worm);
      d = new Date();
      now = d.getTime();
      this.lastTime = now + 100;
      this.canvas.width = 500;
      this.canvas.height = 500;
      this.context.fillStyle = "rgb(0,0,0)";
      this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
      this.context.fillStyle = "rgb(255,0,0)";
      document['onkeydown'] = __bind(function(e) {
        return this.onKeyDown(e);
      }, this);
      document['onkeyup'] = __bind(function(e) {
        return this.onKeyUp(e);
      }, this);
      setInterval((__bind(function() {
        return this.timestep();
      }, this)), 50);
    }
    Viper.prototype.timestep = function() {
      var crawl, d, elapsed, now, worm, _i, _len, _ref;
      d = new Date();
      now = d.getTime();
      if (this.lastTime > now) {
        return false;
      }
      elapsed = now - this.lastTime;
      crawl = __bind(function(worm) {
        if (worm.alive) {
          worm.move(elapsed);
          worm.draw(this.context);
          return this.collisionTest(worm);
        }
      }, this);
      _ref = this.worms;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        worm = _ref[_i];
        crawl(worm);
      }
      this.score.innerHTML = "Score: " + worm.score;
      this.lastTime = now;
      return true;
    };
    Viper.prototype.collisionTest = function(worm) {
      var test, _i, _len, _ref, _results;
      test = function(otherWorm) {
        var result;
        result = otherWorm.collisionTest(worm.segments[worm.segments.length - 1]);
        if (result === 2) {
          return worm.alive = false;
        } else if (result === 1) {
          return worm.score += 1;
        }
      };
      _ref = this.worms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        worm = _ref[_i];
        _results.push(test(worm));
      }
      return _results;
    };
    Viper.prototype.onKeyDown = function(e) {
      if (e.keyCode === 37) {
        return this.worms[0].torque = -0.002;
      } else if (e.keyCode === 39) {
        return this.worms[0].torque = 0.002;
      }
    };
    Viper.prototype.onKeyUp = function(e) {
      if (e.keyCode === 37 || e.keyCode === 39) {
        return this.worms[0].torque = 0;
      }
    };
    return Viper;
  })();
  new Viper();
}).call(this);
