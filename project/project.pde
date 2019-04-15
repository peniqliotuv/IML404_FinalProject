import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Movie movie;

Capture video;
OpenCV opencv;


void setup() {
  size(640, 360);
  Movie.supportedProtocols[0] = "rtsp";

  background(0);
  try
  {
    movie = new Movie(this, "rtsp://hex-cam.wh.oblong.com/h264.sdp?res=half&x0=0&y0=0&x1=1920&y1=1080&qp=20&ratelimit=10000&doublescan=0&ssn=27675");
    print(movie);
    movie.loop();
  }
  catch (Exception e)
  {
    println(e);
  }
}

void movieEvent(Movie m) {
  m.read();
}

void draw() 
{
  image(movie, 0, 0, width, height);
}
