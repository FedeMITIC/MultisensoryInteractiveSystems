import controlP5.*; 
import oscP5.*;
import netP5.*;
 
OscP5 oscP5;


float ballPosition_x = 0;

float angle = 0; //degrees
float GRAVITY = 0.9801;


void setup() {
/* start oscP5 and listen for incoming messages at port 7777*/
  oscP5 = new OscP5(this,7777);
  println("so this is the setup\n");
  
  size(600, 600, P2D);
  
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
  translate(300, 300); // (half board width, ...)
  

  
  rotate(radians(angle)); // rotates the coordinate system by the angle received by pd
  //popMatrix();
  rectMode(CENTER);
  rect(0, 400, 1200, 800); 
  
  ellipseMode(CENTER); // ref. point to ellipse is its center
  ellipse(ballPosition_x, -10, 20, 20);
 
  // increment x and y
  ballPosition_x += 9.81 * sin(radians(angle));
  
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
