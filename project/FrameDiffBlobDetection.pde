import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

Capture video;
Movie movie;
OpenCV opencv;

PImage prevFrame;

int blobCount = 0;
float DIST_THRESHOLD = 50;
float BLOB_SIZE_THRESHOLD = 5;

ArrayList<Contour> contours;
ArrayList<Contour> newBlobContours;
ArrayList<Blob> blobList = new ArrayList<Blob>();

void setup() {
  size(960, 540);
  frameRate(60);
  
  //Movie.supportedProtocols[0] = "rstp";
  
  //background(0);
  //try {
  //  movie = new Movie(this, "rtsp://hex-cam.wh.oblong.com/h264.sdp?res=half&x0=0&y0=0&x1=1920&y1=1080&qp=20&ratelimit=10000&doublescan=0&ssn=27675");
  //  movie.loop();
  //} catch (Exception e) {
  //  e.printStackTrace();
  //  print("Error");
  //}
  
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, width, height); 
  video.start();
}

void draw() {
  if (prevFrame != null) {
    opencv.loadImage(prevFrame);
    opencv.diff(video);
    opencv.adaptiveThreshold(300, 50);
    //opencv.gray();
    //opencv.brightness(1);
    opencv.contrast(2);
    //opencv.dilate();
    // opencv.erode();
    // opencv.blur(4);
    // opencv.invert();
    PImage frameDiff = opencv.getSnapshot();
    
    background(frameDiff);
    
    println("== CURR BLOBS: " + blobList.size() + " ==");
    detectBlobs();
    displayBlobs();
  }
  
  prevFrame = video;
}

void captureEvent(Capture c) {
  c.read();
}

void movieEvent(Movie m) {
  m.read();
}

void displayBlobs() {
  for (Blob b : blobList) {
    strokeWeight(1);
    b.display();
  }
}

void detectBlobs() {
  contours = opencv.findContours();
  newBlobContours = getBlobsFromContours(contours);
   
  // Case 1: No Blobs Initially
  if (blobList.isEmpty()) {
    for (Contour c : newBlobContours) {
      println("=== NEW BLOB DETECTED WITH ID: " + blobCount);
      blobList.add(new Blob(this, blobCount, c));
      blobCount++;
    }
  // Case 2: Fewer Blobs than found Contours
  } else if (blobList.size() <= newBlobContours.size()) {
    boolean[] used = new boolean[newBlobContours.size()];
    
    // Match existing Blob objects with a Rectangle
    for (Blob b : blobList) {
      // Find the new blob that is closest to b
      // Set used[index] to true so it can't be used twice
      float closestDistance = 100000; 
      int closestBlobIdx = -1;
      for (int i = 0; i < newBlobContours.size(); i++) {
        Rectangle contourBB = newBlobContours.get(i).getBoundingBox();
        Rectangle blobBB = b.getBoundingBox();
        
        float distance = dist(contourBB.x, contourBB.y, blobBB.x, blobBB.y);
        if (distance < closestDistance && !used[i]) {
          closestDistance = distance;
          closestBlobIdx = i;
        }
      }
      
      used[closestBlobIdx] = true;
      b.updateFromContour(newBlobContours.get(closestBlobIdx));
    }
     
     // Add any unused blobs
    for (int i = 0; i < newBlobContours.size(); ++i) {
      if (!used[i]) {
        println("=== NEW BLOB DETECTED WITH ID: " + blobCount);
        blobList.add(new Blob(this, blobCount, newBlobContours.get(i)));
        blobCount++;
      }
    }
  // Case 3: More Blobs than Contours in the frame
  } else {
    // Set all blobs to available
    for (Blob b : blobList) {
      b.availableToMatch = true;
    }
    
    for (int i = 0; i < newBlobContours.size(); i++) {
      // Find blob object closest to the current contour
      float closestDistance = 100000;
      int closestBlobIdx = -1;
      for (int j = 0; j < blobList.size(); ++j) {
        Blob b = blobList.get(j);
        Rectangle blobBB = b.getBoundingBox();
        Rectangle contourBB = newBlobContours.get(i).getBoundingBox();
        
        float distance = dist(contourBB.x, contourBB.y, blobBB.x, blobBB.y);
        
        if (distance < closestDistance && b.availableToMatch) {
          closestDistance = distance;
          closestBlobIdx = j;
        }
      }
      
      // Update Blob
      Blob b = blobList.get(closestBlobIdx);
      b.availableToMatch = false;
      b.updateFromContour(newBlobContours.get(i));
    }
    
    for (Blob b : blobList) {
      if (b.availableToMatch) {
        b.countDown();
        if (b.dead()) {
          b.delete = true;
        } 
      }
    } 
  }
  
  // Kill Remaining Blobs
  for (int i = blobList.size() - 1; i >= 0; --i) {
    Blob b = blobList.get(i);
    if (b.delete) {
      blobList.remove(i);
    }
  }
}

// Filter blobs that are smaller than the blob size threshold
ArrayList<Contour> getBlobsFromContours(ArrayList<Contour> newContours) {
  ArrayList<Contour> newBlobs = new ArrayList<Contour>();
  
  for (int i = 0; i < newContours.size(); i++) {
    Contour contour = newContours.get(i);
    Rectangle r = contour.getBoundingBox();
    
    if (r.width < BLOB_SIZE_THRESHOLD || r.height < BLOB_SIZE_THRESHOLD || r.width > 100 || r.height > 100) {
      // Too small
      continue;
    }
    
    newBlobs.add(contour);
  }
  
  return newBlobs;
}
