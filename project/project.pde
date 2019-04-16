import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Movie movie;

Capture video;
OpenCV opencv;

PImage prevImage;

void setup() {
  size(960, 528);
  Movie.supportedProtocols[0] = "rtsp";
  opencv = new OpenCV(this, width, height);
  background(0);
  try
  {
    movie = new Movie(this, "rtsp://hex-cam.wh.oblong.com/h264.sdp?res=half&x0=0&y0=0&x1=1920&y1=1080&qp=20&ratelimit=10000&doublescan=0&ssn=27675");
    println(movie);
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
  //println("In Movie Event");
  // print("Width: " + m.width);
   
  //print(" Height: " + m.height);
  //println();
}

void draw() 
{
  //image(movie, 0, 0, width, height);
  if (prevImage != null) {
    //println("PrevImage dimensions: " + prevImage.width + " " + prevImage.height);
    opencv.loadImage(prevImage);
    opencv.diff(movie);
    PImage snapshot = opencv.getSnapshot();
    image(snapshot, 0, 0, width, height);
  } else {
    //print(prevImage);
  }
  
  prevImage = movie;
}
