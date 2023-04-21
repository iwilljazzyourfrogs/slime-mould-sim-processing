class Agent {
  PVector pos;
  PVector dir;
  
  Agent(PVector p, float d) {
    pos = p;
    dir = new PVector(speed * cos(d), speed * sin(d));
  }
  
  void update() {
    pos.add(dir);
    if (reflect) {
      if (!(0 <= pos.x && pos.x < width)) {
        dir.x *= -1;
      } if (!(0 <= pos.y && pos.y < height)) {
        dir.y *= -1;
      }
    } else {
      if (!(0 <= pos.x && pos.x < width) || !(0 <= pos.y && pos.y < height)) {
        dir.rotate(random(TWO_PI));
      }
    }
    
    float f = sense(0);
    float l = sense(senseAngle);
    float r = sense(-senseAngle);
    
    
    if (randomTurn) {
      if (f < l || f < r) {
        if (l == r) {
          dir.rotate(0);
        } else if (l > r) {
          dir.rotate(sqrt(random(1)) * turnSpeed);
        } else if (r > l) {
          dir.rotate(-sqrt(random(1)) * turnSpeed);
        }
      }
    } else {
      if (f < l || f < r) {
        if (l > r) {
          dir.rotate(turnSpeed);
        } else if (r > l) {
          dir.rotate(-turnSpeed);
        }
      }
    }
  }
  
  void render() {
    if (0 <= pos.x && pos.x < width && 0 <= pos.y && pos.y < height) {
      trailMap[(int)pos.x][(int)pos.y] = 1;
    }
  }
  
  float sense(float angle) {
    PVector sensorDir = new PVector(senseDist * cos(angle + dir.heading()), senseDist * sin(angle + dir.heading()));
    PVector sensorPos = new PVector(pos.x + sensorDir.x, pos.y + sensorDir.y);
    if (0 <= sensorPos.x && sensorPos.x < width && 0 <= sensorPos.y && sensorPos.y < height) {
      return trailMap[(int)sensorPos.x][(int)sensorPos.y];
    }
    return 0;
  }
}
