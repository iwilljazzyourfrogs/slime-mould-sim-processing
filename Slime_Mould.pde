final int numAgents = 10000;
Agent[] agents = new Agent[numAgents];

final boolean printFPS = false;
final int perFrame = 1;

final String edgeBehaviour = "reflect";
final boolean randomTurn = true;

final String genMode = "circle";
final float noiseScale = 100;

final float speed = 1;
final float turnStrength = 0.5;
final float senseAngle = PI / 6.0;
final float turnSpeed = turnStrength * senseAngle;
final float senseDist = 32;

final float falloff = 0.005;
final int blurRad = 1;
final float colorFalloff = 0.1;

float[][] trailMap;
float[][] trailMapPrev;

PVector randomPointInCircle(float r, PVector c) {
  float theta = random(TWO_PI);
  float dist = r * sqrt(random(1));
  return new PVector(dist * cos(theta) + c.x, dist * sin(theta) + c.y);
}

void setup() {
  size(1080,720);
  //frameRate(24);
  for (int i = 0; i < numAgents; i++) {
    switch(genMode) {
      case "circle":
        agents[i] = new Agent(randomPointInCircle(width / 5, new PVector(width / 2, height / 2)), random(TWO_PI));
        break;
      case "rand":
        agents[i] = new Agent(new PVector(random(width), random(height)), random(TWO_PI));
        break;
      case "noisePos":
        agents[i] = new Agent(new PVector(width * noise(i / noiseScale), height * noise(i / noiseScale + 1000)), random(TWO_PI));
        break;
      case "noiseDir":
        int j = (int)map(i, 0, numAgents, 0, width * height);
        int x = j % width;
        int y = j / width;
        agents[i] = new Agent(new PVector(x, y), TWO_PI * noise(x / noiseScale, y / noiseScale + 100));
        break;
    }
  }
  
  trailMap = new float[width][height];
  trailMapPrev = new float[width][height];
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      trailMap[x][y] = 0;
      trailMapPrev[x][y] = 0;
    }
  }
  
  colorMode(RGB, 1);
  background(0);
  stroke(1);
  strokeWeight(1);
}

void draw() {
  if (frameCount % 60 == 0 && printFPS) {
    println(frameRate);
  }
  for (int c = 0; c < perFrame; c++) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (trailMap[x][y] > 0) {
          trailMapPrev[x][y] -= falloff;
        }
        float sum = 0;
        for (int dx = -blurRad; dx <= blurRad; dx++) {
          int ox = x + dx;
          for (int dy = -blurRad; dy <= blurRad; dy++) {
            int oy = y + dy;
            if (0 <= ox && ox < width && 0 <= oy && oy < height) {
              sum += trailMapPrev[ox][oy];
            }
          }
        }
        trailMap[x][y] = (sum / pow(2 * blurRad + 1, 2));
        
      }
    }
    
    for (Agent a : agents) {
      a.update();
      a.render();
    }
    float[][] temp = trailMap;
    trailMap = trailMapPrev;
    trailMapPrev = temp;
  }  
  loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int index = x + y * width;
      pixels[index] = color(pow(trailMapPrev[x][y], colorFalloff));
    }
  }
  updatePixels();
}
