import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Movie movie;

Capture video;
OpenCV opencv;

PImage prevImage;
ShimodairaOpticalFlow SOF = null;
PVector center;

PVector forward = new PVector(0, -1);
void setup() {
  size(960, 528);
  
  
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture. Exiting application");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
     
    Capture cam = new Capture(this, width, height, cameras[0]);
    cam.start();
    
    SOF = new ShimodairaOpticalFlow(cam);
  }
  
  center = new PVector(width/2, height/2);
  background(0);
  //try
  //{
  //  movie = new Movie(this, "rtsp://hex-cam.wh.oblong.com/h264.sdp?res=half&x0=0&y0=0&x1=1920&y1=1080&qp=20&ratelimit=10000&doublescan=0&ssn=27675");
  //  movie.loop();
  //}
  //catch (Exception e)
  //{
  //  println(e);
  //}
  println(width);
  println(height);
  println("Setup finished");
}


//void movieEvent(Movie m) {
//  m.read();

//  if (SOF == null) {
//    SOF = new ShimodairaOpticalFlow(m);
//  }
//  SOF.calculateFlow(m);
//}
boolean hasOpened = false;

void draw() 
{
  background(0);
  if (SOF.flagimage) set(0, 0, SOF.cam);
  else background(120);
  
  // calculate optical flow
  SOF.calculateFlow();

  // draw the optical flow vectors
  if (SOF.flagflow) {
    SOF.drawFlow();
  }
    
   PVector centerOfMass = SOF.drawAndGetCenterOfMass();
   float x = centerOfMass.x;
   float y = centerOfMass.y;
  
   //println("x: " + x + " y: " + y);
   float dist = center.dist(centerOfMass);
   PVector direction = centerOfMass.sub(center);
   float angle = PVector.angleBetween(direction, forward);
   
   if (x <= width / 2) {
     angle += PI;
   }
   float deltaX = x - width/2;
   float deltaY = y - height/2;
   
   String command = formatTranslationCommand(deltaX, deltaY);
   println(command);
   
   try {
     Process p = exec(command.split(" "));
     p.waitFor();
     int exitVal = p.exitValue();
     println(exitVal);
   } catch (Exception e) {
     println(e.getMessage());
   }
   
   //println("Angle: " + degrees(angle));
   //println("Dist: " + dist);
}

String formatTranslationCommand(float x, float y) {
  StringBuilder sb = new StringBuilder("poke -d set-translation -i translation:[");
  sb.append((int) (300 + x));
  sb.append(",360,");
  sb.append((int) (-500 + y));
  sb.append("] tcp://10.137.124.205/kepler");
  return sb.toString();
}
