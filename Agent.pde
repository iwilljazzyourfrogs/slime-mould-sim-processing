class Agent {
  PVector pos;
  PVector dir;
  
  Agent(PVector p, float d) {
    pos = p;
    dir = new PVector(speed * cos(d), speed * sin(d));
  }
  
  void update() {
    pos.add(dir);
    
    switch(edgeBehaviour) {
      case "reflect":
        if (!(0 <= pos.x && pos.x < width)) {
          dir.x *= -1;
        } if (!(0 <= pos.y && pos.y < height)) {
          dir.y *= -1;
        }
        break;
      case "rand":
        if (!(0 <= pos.x && pos.x < width) || !(0 <= pos.y && pos.y < height)) {
          dir.rotate(random(TWO_PI));
        }
        break;
      case "loop":
        pos.x = (pos.x + width) % width;
        pos.y = (pos.y + height) % height;
        break;
      case "center":
        if (!(0 <= pos.x && pos.x < width) || !(0 <= pos.y && pos.y < height)) {
          pos = new PVector(width / 2, height / 2);
        }
        break;
      case "centerRand":
        if (!(0 <= pos.x && pos.x < width) || !(0 <= pos.y && pos.y < height)) {
          pos = new PVector(width / 2, height / 2);
          dir.rotate(random(TWO_PI));
        }
        break;
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
    switch(edgeBehaviour) {
      case "center":
      case "centerRand":
        if (0 <= sensorPos.x && sensorPos.x < width && 0 <= sensorPos.y && sensorPos.y < height) {
          return trailMap[(int)sensorPos.x][(int)sensorPos.y];
        }
        return trailMap[width / 2][height / 2];
      case "loop":
        return trailMap[(int)(sensorPos.x + width) % width][(int)(sensorPos.y + height) % height];
      default:
        if (0 <= sensorPos.x && sensorPos.x < width && 0 <= sensorPos.y && sensorPos.y < height) {
          return trailMap[(int)sensorPos.x][(int)sensorPos.y];
        }
        return 0;
    }
  }
}
