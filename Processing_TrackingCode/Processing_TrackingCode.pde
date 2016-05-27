/*
  This code is free software: you can redistribute it and/or modify 
  it under the terms of the GNU General Public License as published 
  by the Free Software Foundation, either version 3 of the License, 
  or (at your option) any later version.
  This code is distributed in the hope that it will be useful, but 
  WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
  General Public License for more details.
  You should have received a copy of the GNU General Public License
  along with this code. If not, see <http://www.gnu.org/licenses/>.
*/

/* Code logic in short:
  The code reads the webcam image
  Detects contours
  Filter contours based on size
  Checks whether contour is new or a movement of an existing contour based on a threshold
  Reoccuring contours are saved as blobs
  The first blob is assigned as being pacman, you can also click on another blob to switch pacman
  A matrix of dots is drawn
  In case pacman is near a dot, it gets destroy and score + 1
*/

/* Most important values for tracking:
contourTreshold
sizeTreshold
/*

/* Load libraries */
import gab.opencv.*;              // Load library https://github.com/atduskgreg/opencv-processing
import processing.video.*;        // Load video camera library 

/* Declare variables */
Capture video;                    // Camera stream
OpenCV opencv;                    // OpenCV
PImage now, diff;                 // PImage variables to store the current image and the difference between two images 

PGraphics drawing;                // PGraphics buffer

ArrayList<Contour> contours;      // ArrayList to hold all detected contours
ArrayList<Blob> blobs = new ArrayList <Blob>(); // ArrayList to hold all blobs

PFont font;                       //  A new font object

int ContourThreshold = 20;        //  Contour detection sensitivity of the script
int SizeThreshold = 100;          //  Contour size threshold
int MovementMargin = 40;          //  Max difference in coordinates
int segmentSize = 5;
int segmentThreshold = segmentSize * segmentSize / 3;

/* Slider Bar */
HScrollbar hs1, hs2;
Boolean scroll_lock = false;

/* Setup function */
void setup() {
  size(640, 960);  //  Create canvas window                  
  
  // Select camera: print all available cameras in a list
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i, cameras[i]);
    }
  }      
  // select the number of the webcam camera from the list
 // video = new Capture(this, 640, 480, cameras[12], 30);    //  Define video size, with webcam plugged in
  video = new Capture(this, 640, 480, cameras[8], 30); 
  opencv = new OpenCV(this, 640, 480);    //  Define opencv size

  video.start();                          //  Start capturing video        

  font = loadFont("Serif-48.vlw");        //  Load the font file into memory
  textFont(font, 12);                     //  Set font size
  strokeWeight(3);                        //  Set stroke size
  
  noStroke();
  hs1 = new HScrollbar(0, height/2-8, width, 16, 16);
  hs2 = new HScrollbar(0, height/2+8, width, 16, 16);
}

/* Draw function */
void draw() { 
  
  // start buffer
  drawing = createGraphics(640, 480);
  drawing.beginDraw();
  drawing.noStroke();
  int[] segments = new int[int(640/segmentSize)*int((480)/segmentSize)];  //  Set number segments
  
  opencv.loadImage(video);   //  Capture video from camera in OpenCV
  
  image(video, 0, 0);        //  Draw camera image to screen 
  
  opencv.gray();             //  Convert into gray scale
  //opencv.contrast(2);        //  Increase contrast
  opencv.invert();           //  Invert b/w
  //opencv.blur(3);            //  Reduce camera noise
  opencv.threshold(ContourThreshold);  //  Convert to Black and White
  //opencv.flip(OpenCV.VERTICAL); // Flip image vertical
  
  now = opencv.getOutput();   //  Store image in PImage
  image(now, 0, 480);         //  Show video (black and white)

  // Analyze image
  int segmentCounter = 0;
  for( int x = 1; x < 640; x = x + segmentSize) {
    for ( int y = 1; y < 480; y = y + segmentSize) {
      
      int segmentBrightness = 0;
      for ( int i = 0; i < segmentSize; i++) {
        for ( int j = 0; j < segmentSize; j++) {
          if (brightness(now.pixels[x+i+(y*width)+j]) > 127) {
            segmentBrightness++;
          }
        }
      }
      if(segmentBrightness > segmentThreshold) { //  segment is bright
        segments[segmentCounter] = 1;
        drawing.fill(255,255,255);
        drawing.rect(x-1,y-1,12,12);
      }
      segmentCounter++;
    }  
  }

  drawing.endDraw();

  // Draw the offscreen buffer to the screen with image() 
  image(drawing, 0, 0);
  
  //opencv.loadImage(drawing);
  
  // Analyze video
  contours = opencv.findContours();         //  Find contours
  
  int evalc = 0;                            //  Count number of evaluated contours
  for (Contour contour : contours) {        //  Loop through all contours
    int sumx = 0;        //  Sum of all x coordinates
    int sections = 0;    //  # of sections
    int sumy = 0;        //  Sum of all y coordinates
    int area = 0;        //  Area of polygon
    
    ArrayList<Integer> Xcoors = new ArrayList<Integer>();  // List of all X coordinates
    ArrayList<Integer> Ycoors = new ArrayList<Integer>();  // List of all Y coordinates
    
    for (PVector point : contour.getPolygonApproximation().getPoints()) {  // Loop through all vertex X Y coordinates of polygon
      sumx = sumx + int(point.x);  //  Sum up all X coordinates, needed for calculating the middle
      sumy = sumy + int(point.y);  //  Sum up all Y coordinates, needed for calculating the middle
      Xcoors.add(int(point.x));    //  Store all X coordinates, needed for calculating the area
      Ycoors.add(int(point.y));    //  Store all Y coordinates, needed for calculating the area
      sections++;                  //  Count the number of sections
    }
    
    // Calculate the area of the polygon
    int j = 0;
    for (int i = 0; i < sections; i++) {
      area = area + (Xcoors.get(j)+Xcoors.get(i)) * (Ycoors.get(j)-Ycoors.get(i));
      j = i;
    }
    area = area / 2;
    
    if(area > SizeThreshold && area < 100000) {  // Check whether area is above threshold and not as big as the video itself
      evalc++;            //  Up 1 for the evaluated contours counter
      noFill();           //  Disable filled shapes
      stroke(0, 255, 0);  //  Set stroke color to green
      contour.draw();     //  Draw the contour
      fill(255, 0, 0);    //  Set color to red
      text((sumx/sections) + ", " + (sumy/sections), (sumx/sections), (sumy/sections)); // Print the coordinates on screen
    
      if(blobs.size() > 0) {  //  Check whether this is the first blob or not
        boolean withinmargin = false;    //  Flag whether it is close to a previous blob
        int withinmarginID = 0;          //  Remember which one that was
        
        for( int i = 0; i < blobs.size(); i++) { //  Loop through all blobs
          Blob _blob = (Blob) blobs.get(i);      //  Make a temp copy
          int lastX = _blob.blobX.get(_blob.blobX.size()-1); //  most recent X coordinate
          int lastY = _blob.blobY.get(_blob.blobY.size()-1); //  most recent Y coordinate
          
          // Check whether the contour is within movement margin, otherwise it's a new blob
          if(lastX < (sumx/sections + MovementMargin)){
            if(lastX > (sumx/sections - MovementMargin)) {
              if(lastY < (sumy/sections + MovementMargin)) {
                if(lastY > (sumy/sections - MovementMargin)) {
                    withinmargin = true;
                    withinmarginID = i;
                    // println("hit X old: " + lastX + "; new:" + sumx/c + "; Y old: " + lastY + "; Y new: " +sumy/c);
                 }
              }
            }
          }
          
          _blob = null; // Reset temp copy
        }
        
        if(withinmargin) {                                               //  Within margin? True: add coordinates to ArrayList
          Blob _blob = (Blob) blobs.get(withinmarginID);                 //  Make temp copy of blob
          _blob.addXYSA(sumx/sections, sumy/sections, sections, area);   //  Add the information to the ArrayLists of the blob object
          blobs.set(withinmarginID, _blob);                              //  Store the blob
        } else {                                                         //  else: it's a new blob
          blobs.add(new Blob(sumx/sections, sumy/sections, sections, area, false));  // Add new blob to the blobs ArrayList
        }
      } else { // Add first blob, which becomes PacMan
        blobs.add(new Blob(sumx/sections, sumy/sections, sections, area, true));  // Store blob and flag as PacMan
      }
    }
  }
  
  // Print some useful monitoring info to the console
  println("Found " + contours.size() + " Contours; area > "+SizeThreshold+" px " + evalc + "; Total "+ blobs.size() + " blobs" + " mouseX: " + mouseX);


  ContourThreshold = int(hs1.getPos()); // get scrollbar position
  fill(0,0,255);  // Set color to blue
  textSize(20); // Increase text size
  text("CountourThreshold: " + ContourThreshold, 20, 40);
  
  int  multiplySizeTreshold = 2; // variable for multiplying the Sizetreshold 
  SizeThreshold = int(hs2.getPos()) * multiplySizeTreshold; // NEW: multiply w/ 100 to get a bigger max SizeTreshold
  // SizeThreshold = int(hs2.getPos());
  text("SizeThreshold: " + SizeThreshold * 10, 30, 60);
  
  scroll_lock = hs1.update(scroll_lock);
  scroll_lock = hs2.update(scroll_lock);
  hs1.display();
  hs2.display();
  
  // Wait a little before the next round to save processing power and memory
  delay(40);
}

/* Capture function */
void captureEvent(Capture c) {
  c.read();
}