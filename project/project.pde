import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Movie movie;

Capture video;
OpenCV opencv;

PImage prevImage;
ShimodairaOpticalFlow SOF = null;

void setup() {
  size(960, 528);
  Movie.supportedProtocols[0] = "rtsp";
  opencv = new OpenCV(this, width, height);
  background(0);
  try
  {
    movie = new Movie(this, "rtsp://hex-cam.wh.oblong.com/h264.sdp?res=half&x0=0&y0=0&x1=1920&y1=1080&qp=20&ratelimit=10000&doublescan=0&ssn=27675");
    movie.loop();
  }
  catch (Exception e)
  {
    println(e);
  }
  println(width);
  println(height);
  println("Setup finished");
}


void movieEvent(Movie m) {
  m.read();

  if (SOF == null) {
    SOF = new ShimodairaOpticalFlow(m);
  }
  SOF.calculateFlow(m);
}

void draw() 
{
  background(0);
  if (prevImage != null) {
    //println("PrevImage dimensions: " + prevImage.width + " " + prevImage.height);
    //opencv.loadImage(prevImage);
    //opencv.diff(movie);
    //PImage snapshot = opencv.getSnapshot();
    //image(snapshot, 0, 0, width, height);
    //SOF.calculateFlow();
    //if (shouldDrawFlow) {
    SOF.drawFlow();
    SOF.drawCenterOfMass();
      //shouldDrawFlow = false;
    //}
  }
  
  prevImage = movie;
}
