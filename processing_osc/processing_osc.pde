import controlP5.*; 
import oscP5.*;
import netP5.*;
 
OscP5 oscP5;

float ballPosition_x = 0;
float prevBallPosition = 0;
float angle = 0; //degrees
boolean experimentStarted = false;
boolean experimentCompleted = false; // Used to block.
boolean isInTargetArea = false;  // Check if the ball is in the target area

// Constants
final float GRAVITY = 9.82715;     // m/s^2 for Trento, Italy
final int B_THRESHOLD = 10;        // Threshold for the boundary
final int LEFT_BOUNDARY = -700 + B_THRESHOLD;
final int RIGHT_BOUNDARY = 700 - B_THRESHOLD;
final float ANGLE_ZERO_THRESHOLD = 2.5;


final int SCENARIO = 1;
final int BALL_DIM = 20;
final int TARGET_X = 500;
final int TARGET_Y = 4;
final int TARGET_DIM_L = 50;
final int REV_TARGET_X = -500;
float time = 0.0;


class Timer {
  int startTime = 0; 
  int stopTime = 0;
  boolean running = false;  
  void start() {
      startTime = millis();
      running = true;
  }
  void stop() {
      stopTime = millis();
      running = false;
  }
 int getElapsedTime() {
    return (stopTime - startTime);
  }
}

Timer timer = new Timer(); 

void setup() {
/* start oscP5 and listen for incoming messages at port 7777*/
  oscP5 = new OscP5(this,7777);
  println("Connection Setup completed");
  
  size(1400, 800, P2D);
  smooth(3); // bicubic anti-aliasing
   
  // Shapes and objects will be filled with white by default
  fill(255,255,255);
  
  // Shaped and objects will have a white border by default,
  // unless specified otherwise.
  stroke(255);
}

void draw(){
  background(0);
  fill(250,250,250);  
  
  //pushMatrix();
  translate(700, 400); // (half board width, ...)
  
  if(!experimentStarted) {
    String t = "WELCOME TO SCENARIO " + SCENARIO;
    textSize(24);
    text(t, -650, -350);
    textSize(18);
    text("Tilt the board to start the experiment", -650, -320);
  }
  
  rotate(radians(angle)); // rotates the coordinate system by the angle received by pd
  rectMode(CENTER);
  rect(0, 400, 2000, 800); 
  
  ellipseMode(CENTER); // ref. point to ellipse is its center
  ellipse(ballPosition_x, -10, BALL_DIM, BALL_DIM);
  
  // To position the target and prepare the messages for PD
  switch(SCENARIO) {
    case 1: // Scenario 1: no feedback
      fill(255, 0, 0);  // Red
      rect(TARGET_X, TARGET_Y, TARGET_DIM_L, 10); //<>//
      break;
    case 2: // Scenario 2: haptic feedback
      break;
    case 3: // Scenario 3: auditory feedback
      break;
    case 4: // Scenario 4: auditory + haptic feedback
      break;
    default: println("Select a Scenario [1-4]!");
      break;
  }
 
  // increment x and y
  float acc = GRAVITY * sin(radians(angle));
  
  if (prevBallPosition + acc >= RIGHT_BOUNDARY || prevBallPosition + acc <= LEFT_BOUNDARY) {
    // The ball will move out of boundary, so block it
    ballPosition_x = prevBallPosition;
  } else {
    // The movement is OK, move the ball and save the original position for the next iteration
    ballPosition_x += acc;
    prevBallPosition = ballPosition_x;
    // Check if the ball is now in the target area
    checkTarget();
  }
}

void checkTarget() {
  if ((int)ballPosition_x + BALL_DIM >= TARGET_X && (int)ballPosition_x + BALL_DIM <= TARGET_X + TARGET_DIM_L) {
    // The virtual ball is inside the target; the experiment is completed if it stays there
    isInTargetArea = true;
  } else {
    isInTargetArea = false;
  }
}

boolean isZero(float n) {
  return (n >= -ANGLE_ZERO_THRESHOLD && n <= ANGLE_ZERO_THRESHOLD);
}

/*
 * The angle received is always a float with one decimal
 */
void oscEvent(OscMessage theOscMessage) {
  // If the experiment is completed, close the interface
  if(experimentCompleted) {
    timer.stop();
    int elapsedTime = timer.getElapsedTime();
    println("[", SCENARIO, "]", "Experiment completed");
    println("[", SCENARIO, "]", "Elapsed time: ", elapsedTime, "ms", "(", ((float)elapsedTime / 1000) % 60, ")");
    // 3 seconds delay before quitting the UI (remove to calculate the exact experiment time)
    delay(3000);
    exit();
  }
  if(theOscMessage.checkAddrPattern("/angle")) {
    if(theOscMessage.checkTypetag("f")) {
      // The first time a message is received the experiment is started and the timer starts.
      float floatAngle = theOscMessage.get(0).floatValue();
      angle = floatAngle;
      // If the experimented is not yet started and the angle is not 0°, then the user tilted the plank for the first time 
      if(!experimentStarted && !isZero(angle)) {
        println("[", SCENARIO, "]", "Experiment started");
        experimentStarted = true;
        timer.start();
      }
    }
  }
  // Since it is difficult to get exactly 0° degree of roll, this threshold should help
  if(isZero(angle)) {
    angle = 0.0;
    if (isInTargetArea && experimentStarted) {
      experimentStarted = false;
      experimentCompleted = true;
      // To ensure that the timer stops immediately
    }
  }
}
