    /*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    */
import processing.serial.*;

int SIDE_LENGTH = 500;
int ANGLE_BOUNDS = 180;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 10;
int POINTS_HISTORY_SIZE = 500;
int MAX_DISTANCE = 100;

int angle;
int distance;

int radius;
float x, y;
float leftAngleRad, rightAngleRad;

float[] historyX, historyY;
Point[] points;

int centerX, centerY;

String comPortString;
Serial myPort;

void setup() {
  size(SIDE_LENGTH, SIDE_LENGTH, P2D);
  noStroke();
  //smooth();
  rectMode(CENTER);

  radius = SIDE_LENGTH / 2;
  centerX = width / 2;
  centerY = height / 2;
  angle = 0;
  leftAngleRad = radians(-ANGLE_BOUNDS) - HALF_PI;
  rightAngleRad = radians(ANGLE_BOUNDS) - HALF_PI;

  historyX = new float[HISTORY_SIZE];
  historyY = new float[HISTORY_SIZE];
  points = new Point[POINTS_HISTORY_SIZE];

  myPort = new Serial(this, "COM3", 9600);
  myPort.bufferUntil('\n'); // Trigger a SerialEvent on new line
}


void draw() {

  background(0);

  drawRadar();

  drawFoundObjects(angle, distance);
  drawRadarLine(angle);
}

void drawRadarLine(int angle) {

  float radian = radians(angle);
  x = radius * sin(radian);
  y = radius * cos(radian);


  float px = centerX + x;
  float py = centerY - y;

  historyX[0] = px;
  historyY[0] = py;
  for (int i=0;i<HISTORY_SIZE;i++) {

    stroke(50, 150, 50, 255 - (25*i));
    line(centerX, centerY, historyX[i], historyY[i]);
  }
  shiftHistoryArray();
}

void drawFoundObjects(int angle, int distance) {


  if (distance > 0) {
    float radian = radians(angle);
    x = distance * sin(radian);
    y = distance * cos(radian);

    int px = (int)(centerX + x);
    int py = (int)(centerY - y);

    points[0] = new Point(px, py);
  } 
  else {
    points[0] = new Point(0, 0);
  }
  for (int i=0;i<POINTS_HISTORY_SIZE;i++) {

    Point point = points[i];
    if (point != null) {

      int x = point.x;
      int y = point.y;

      if (x==0 && y==0) continue;

      int colorAlfa = (int)map(i, 0, POINTS_HISTORY_SIZE, 20, 0);
      int size = (int)map(i, 0, POINTS_HISTORY_SIZE, 30, 5);

      fill(50, 150, 50, colorAlfa);
      noStroke();
      ellipse(x, y, size, size);
    }
  }

  shiftPointsArray();
}

void drawRadar() {
  stroke(100);
  noFill();

  // casti kruznic vzdalenosti od stredu
  for (int i = 0; i <= (SIDE_LENGTH / 100); i++) {
    arc(centerX, centerY, 100 * i, 100 * i, leftAngleRad, rightAngleRad);
  }

  // ukazatele uhlu
  for (int i = 0; i <= (ANGLE_BOUNDS*2/20); i++) {
    float angle = -ANGLE_BOUNDS + i * 20; 
    float radAngle = radians(angle);
    line(centerX, centerY, centerX + radius*sin(radAngle), centerY - radius*cos(radAngle));
  }
}

void shiftHistoryArray() {

  for (int i = HISTORY_SIZE; i > 1; i--) {

    historyX[i-1] = historyX[i-2];
    historyY[i-1] = historyY[i-2];
  }
}

void shiftPointsArray() {

  for (int i = POINTS_HISTORY_SIZE; i > 1; i--) {

    Point oldPoint = points[i-2];
    if (oldPoint != null) {

      Point point = new Point(oldPoint.x, oldPoint.y);
      points[i-1] = point;
    }
  }
}

void serialEvent(Serial cPort) {

  comPortString = cPort.readStringUntil('\n');
  if (comPortString != null) {

    comPortString=trim(comPortString);
    String[] values = split(comPortString, ',');
    
    try {
    
      angle = Integer.parseInt(values[0]);
      distance = int(map(Integer.parseInt(values[1]), 1, MAX_DISTANCE, 1, radius));   
    } catch (Exception e) {}
  }
}

class Point {
  int x, y;

  Point(int xPos, int yPos) {
    x = xPos;
    y = yPos;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }
}