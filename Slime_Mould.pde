int numAgents = 10000;
Agent[] agents = new Agent[numAgents];

boolean printFPS = false;
int perFrame = 1;

boolean reflect = true;
boolean randomTurn = false;

float speed = 0.1;
float turnSpeed = 0.1;
float senseAngle = PI / 6.0;
float senseDist = 2;

float falloff = 0.05;
boolean blur = true;
int blurRad = 1;

float[][] trailMap;
float[][] trailMapPrev;

PVector randomPointInCircle(float r, PVector c) {
  float theta = random(TWO_PI);
  float dist = r * sqrt(random(1));
  return new PVector(dist * cos(theta) + c.x, dist * sin(theta) + c.y);
}

void setup() {
  size(256, 256);
  //frameRate(24);
  for (int i = 0; i < numAgents; i++) {
    agents[i] = new Agent(randomPointInCircle(width / 5, new PVector(width / 2, height / 2)), random(TWO_PI));
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
        if (blur) {
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
        } else {
          trailMap[x][y] = trailMapPrev[x][y];
        }
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
      pixels[index] = color(trailMapPrev[x][y]);
    }
  }
  updatePixels();
}
