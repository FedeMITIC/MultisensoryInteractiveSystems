import controlP5.*; 
import oscP5.*;
import netP5.*;
 
// OSC Messages Setup
NetAddress remote;   // Contains the object that sends the network messages
OscP5 oscP5;         // Contains the object that listen to incoming messages

OscMessage motor_message = new OscMessage("/motor");     // Message for scenario 2 & 4
OscMessage speaker_message = new OscMessage("/speaker");   // Message for scenario 3 & 4

float ballPosition_x = 0;
float prevBallPosition = 0;
float angle = 0; //radians
boolean experimentStarted = false;  // Used to start the timer
boolean experimentCompleted = false; // Used to stop the timer
boolean flag = false; // Used to pretty print the output
boolean isInTargetArea = false;  // Check if the ball is in the target area

// Constants
final float GRAVITY = 9.82715;     // m/s^2 for Trento, Italy
final int B_THRESHOLD = 10;        // Threshold for the boundary
final int LEFT_BOUNDARY = -700 + B_THRESHOLD;
final int RIGHT_BOUNDARY = 700 - B_THRESHOLD;
final float ANGLE_ZERO_THRESHOLD = 0.04363323129985824;
final float MASS = 1;

// Motors' constants
final float MAX_PWR = 229.0;  // 90% DC
final float MIN_PWR = 25.0;   // 10% DC
final int OFF = 0;        //  0% DC
final float LIN_SCALE = 0.191;  // Linear scale to map the distance of the ball (0,650] and the power of the motor [0,229]

final int SCENARIO = 2;
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
  /* start oscP5 and listen for incoming messages at port 7777 */
  oscP5 = new OscP5(this, 7777);
  /* oscP5 to send messages to remote destination on port 7778 */
  remote = new NetAddress("10.218.204.154", 7778);
  println("Connection setup completed: see details above.");
  
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
  
  if(!experimentStarted && !experimentCompleted) {
    String t = "WELCOME TO SCENARIO " + SCENARIO;
    textSize(24);
    text(t, -650, -350);
    textSize(18);
    text("Tilt the board to start the experiment", -650, -320);
  }
  
  rotate(angle); // rotates the coordinate system by the angle received by pd
  rectMode(CENTER);
  rect(0, 400, 2000, 800); 
  
  ellipseMode(CENTER); // ref. point to ellipse is its center
  ellipse(ballPosition_x, -10, BALL_DIM, BALL_DIM); //<>//
  
  // To position the target and prepare the messages for PD
  switch(SCENARIO) {
    case 1: // Scenario 1: no feedback
        fill(255, 0, 0);  // Red
        rect(TARGET_X, TARGET_Y, TARGET_DIM_L, 10);
      break;
    case 2: // Scenario 2: haptic feedback
        fill(255, 0, 0);  // Red
        rect(TARGET_X, TARGET_Y, TARGET_DIM_L, 10);
        if (frameCount > 200 && experimentStarted) {  // https://forum.processing.org/two/discussion/8441/making-an-osc-router (thanks sojamo for the brilliant frameCount solution)
          motor_message.clear();
          motor_message = new OscMessage("/motor"); 
          float pwr = applyThreshold(generateLinearScale());  // Remove apply threshold to obtain the real values (instead of the one in the interval 10%-90% DC)
          String motor_command = "[motor,";
          motor_command += (int)pwr;  // Arduino expects an integer.
          motor_command += "]";
          motor_message.add(motor_command);
          oscP5.send(motor_message, remote);
        }
      break;
    case 3: // Scenario 3: auditory feedback
        fill(255, 0, 0);  // Red
        rect(TARGET_X, TARGET_Y, TARGET_DIM_L, 10);
      break;
    case 4: // Scenario 4: auditory + haptic feedback
        fill(255, 0, 0);  // Red
        rect(TARGET_X, TARGET_Y, TARGET_DIM_L, 10);
      break;
    default: println("Select a Scenario [1-4]!");
      break;
  }
 
  // increment x and y
  float acc = MASS * GRAVITY * sin(angle);
  
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

float generateLinearScale() {
  // If the ball is in the target area, turn off both motors and return
  if (isInTargetArea) {
    return 0;
  }
  int distance = 0;
  float pwr = 0;
  // The ball is on the left side of the target area
  if ((int)ballPosition_x < TARGET_X) {
    distance = abs(TARGET_X - (int)ballPosition_x);
    pwr = MAX_PWR - (distance * LIN_SCALE);
  } else {  // The ball is on the right side of the target area
    distance = abs((int)ballPosition_x - (TARGET_X + TARGET_DIM_L));
    pwr = MAX_PWR - (distance * LIN_SCALE);
  }
  return pwr;
}

float applyThreshold(float n) {
  if (n < MIN_PWR) {
    return MIN_PWR;
  }
  if (n > MAX_PWR) {
    return MAX_PWR;
  }
  return n;
}

/*
 * The angle received is always a float with one decimal
 */
void oscEvent(OscMessage theOscMessage) {
  // If the experiment is completed, close the interface
  if(experimentCompleted) {
    timer.stop();
    int elapsedTime = timer.getElapsedTime();
    if(!flag) {
      print("[", SCENARIO, "]", "Experiment completed. ");
      println("Elapsed time: ", elapsedTime, "ms", "(", ((float)elapsedTime / 1000) % 60, "s )");
      flag = true;
    }
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
        println("[", SCENARIO, "]", "Experiment started.");
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
