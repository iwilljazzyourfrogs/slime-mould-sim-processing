final int numAgents = 500;
Agent[] agents = new Agent[numAgents];

final boolean printFPS = false;

final String edgeBehaviour = "rand";

final String genMode = "noise";
final float noiseScale = 100;

final int angleCount = 16;
float[] cosValues = new float[angleCount];
float[] sinValues = new float[angleCount];

final float speed = 0.5;
final float turnStrength = 0.9;
  final float senseAngle = PI / 4;
final float turnSpeed = turnStrength * senseAngle;
final float randTurnChance = 0;
final float senseDist = 3;

final float falloff = 0.05;
final int blurRad = 1;
final int blurW = 2 * blurRad + 1;
final float colorFalloff = 1;

final boolean crossBlur = true;
final int[][] crossBlurOffsets = {
  {0, -1},
  {1, 0}, 
  {0, 1}, 
  {-1, 0}, 
  {0, 0}
};
int numBlurPixels = blurW * blurW;

float[][] trailMap;
float[][] trailMapPrev;

PVector randomPointInCircle(float r, PVector c) {
  float theta = random(TWO_PI);
  float dist = r * sqrt(random(1));
  return new PVector(dist * cos(theta) + c.x, dist * sin(theta) + c.y);
}

void setup() {
  size(256, 256, P2D);
  for (int i = 0; i < numAgents; i++) {
    switch(genMode) {
      case "circle":
        agents[i] = new Agent(randomPointInCircle(width / 5, new PVector(width / 2, height / 2)), random(TWO_PI));
        break;
      case "rand":
        agents[i] = new Agent(new PVector(random(width), random(height)), random(TWO_PI));
        break;
      case "noise":
        agents[i] = new Agent(new PVector(width * noise(i / noiseScale), height * noise(i / noiseScale + 1000)), random(TWO_PI));
        break;
    }
  }
  
  if (crossBlur) {
    numBlurPixels = 5;
  }
  
  trailMap = new float[width][height];
  trailMapPrev = new float[width][height];
  
  for (int i = 0; i < angleCount; i++) {
    float angle = map(i, 0, angleCount, 0, TWO_PI);
    cosValues[i] = cos(angle);
    sinValues[i] = sin(angle);
  }
  
  colorMode(RGB, 1);
}

void draw() {
  if (frameCount % 20 == 0 && printFPS) {
    println(frameRate);
  }
  for (int i = 0; i < width * height; i++) {
    int x = i % width;
    int y = i / width;
    trailMapPrev[x][y] -= falloff;
    float sum = 0;
    if (crossBlur) {
      for (int[] o : crossBlurOffsets) {
        int ox = x + o[0];
        int oy = y + o[1];
        
        if (0 <= ox && ox < width && 0 <= oy && oy < height) {
          if (trailMapPrev[ox][oy] > 0) {
            sum += trailMapPrev[ox][oy];
          }        
        } else {
          sum += 1.0 / numBlurPixels;
        }
      }
    } else {
      for (int d = 0; d < numBlurPixels; d++) {
        int dx = d % blurW - blurRad;
        int dy = d / blurW - blurRad;
        
        int ox = x + dx;
        int oy = y + dy;
        
        if (0 <= ox && ox < width && 0 <= oy && oy < height) {
          if (trailMapPrev[ox][oy] > 0) {
            sum += trailMapPrev[ox][oy];
          }
        } else {
          sum += 1.0 / numBlurPixels;
        }
      }
    }
    trailMap[x][y] = (sum / numBlurPixels);
    
  }
  
  for (Agent a : agents) {
    a.update();
    a.render();
  }
  float[][] temp = trailMap;
  trailMap = trailMapPrev;
  trailMapPrev = temp;
  
  loadPixels();
  for (int i = 0; i < width * height; i++) {
    int x = i % width;
    int y = i / width;
    pixels[i] = color(trailMap[x][y]);
    if (colorFalloff != 1) {
      pixels[i] = color(pow(trailMap[x][y], colorFalloff));
    }
  }
  updatePixels();
}
