import controlP5.*; 
import oscP5.*;
import netP5.*;
 
OscP5 oscP5;


float ballPosition_x = 0;
float prevBallPosition = 0;
float angle = 0; //degrees

// Constants
final float GRAVITY = 9.82715;   // m/s^2 for Trento, Italy
final int B_THRESHOLD = 10;        // Threshold for the boundary
final int LEFT_BOUNDARY = -700 + B_THRESHOLD;
final int RIGHT_BOUNDARY = 700 - B_THRESHOLD;


void setup() {
/* start oscP5 and listen for incoming messages at port 7777*/
  oscP5 = new OscP5(this,7777);
  println("so this is the setup\n");
  
  size(1400, 800, P2D);
  
  // We could have used this function instead of size()
  // fullScreen(P2D);


  
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
  
  rotate(radians(angle)); // rotates the coordinate system by the angle received by pd
  //popMatrix();
  rectMode(CENTER);
  rect(0, 400, 1600, 800); 
  
  ellipseMode(CENTER); // ref. point to ellipse is its center
  ellipse(ballPosition_x, -10, 20, 20);
 
  // increment x and y
  float acc = GRAVITY * sin(radians(angle));
  
  if (prevBallPosition + acc >= RIGHT_BOUNDARY || prevBallPosition + acc <= LEFT_BOUNDARY) { //<>//
    // The ball will move out of boundary, so block it
    ballPosition_x = prevBallPosition; //<>//
  } else {
    // The movement is OK, move the ball and save the original position for the next iteration
    ballPosition_x += acc; //<>//
    prevBallPosition = ballPosition_x; //<>//
  }
  
  
}


void oscEvent(OscMessage theOscMessage) {
  
  if(theOscMessage.checkAddrPattern("/angle")) {
    //println("the field is there");
    //float angle = theOscMessage.get(0).floatValue();
    if(theOscMessage.checkTypetag("f")) {
      float floatAngle = theOscMessage.get(0).floatValue();
      angle = floatAngle;
      // println("the (float) angle is "+ floatAngle);
    } else if (theOscMessage.checkTypetag("i")) {
      int intAngle = theOscMessage.get(0).intValue();
      angle = intAngle;
      // println("the (int) angle is "+ intAngle);
    }
    println("the angle is "+ angle);
  }
}
