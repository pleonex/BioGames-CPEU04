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

int poppedBubbles;                //  Count total number of popped bubbles
ArrayList bubbles;                //  ArrayList to hold the Bubble objects
PImage bubblePNG;                 //  PImage that will hold the image of the bubble
PFont font;                       //  A new font object

int DiffTreshold = 50;            //  Sensitivity of the script

/* Setup function */
void setup() {
  size(640, 480);  //  Create canvas window                  
  
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

  poppedBubbles = 0;                      //  Set score to 0
  bubbles = new ArrayList();              //  Initialises the ArrayList
 
  bubblePNG = loadImage("Euglena.png");    //  Load the bubble image into memory
  font = loadFont("Serif-48.vlw");        //  Load the font file into memory
  
  textFont(font, 22);                     //  Set font size
}

/* Draw function */
void draw() {
  
  // Add one bubble each round at a random x position
  bubbles.add(new Bubble( int(random(0, 600)), (-1 * bubblePNG.height), bubblePNG.width, bubblePNG.height)); 
  
  opencv.loadImage(video);   //  Capture video from camera in OpenCV
  now = opencv.getInput();   //  Store image in PImage
  image(video, 0, 0);        //  Draw camera image to screen 
  
  opencv.blur(3);                  //  Reduce camera noise            
  opencv.diff(now);                //  Difference between two pictures
  opencv.threshold(DiffTreshold);  //  Convert to Black and White
  diff = opencv.getOutput();       //  Store this image in an PImage variable
  
  for ( int i = 0; i < bubbles.size(); i++ ){   //  For every bubble in the bubbles array
    Bubble _bubble = (Bubble) bubbles.get(i);   //  Copies the current bubble into a temporary object
 
    if(_bubble.update() == 1){                  //  If the bubble's update function returns '1'
      bubbles.remove(i);                        //  then remove the bubble from the array
      _bubble = null;                           //  and make the temporary bubble object null
      i--;                                      //  since we've removed a bubble from the array, we need to subtract 1 from i, or we'll skip the next bubble
    }else{                                      //  If the bubble's update function doesn't return '1'
      bubbles.set(i, _bubble);                  //  Copies the updated temporary bubble object back into the array
      _bubble = null;                           //  Makes the temporary bubble object null.
    }
  }
    
  text("Bubbles popped: " + poppedBubbles, 20, 40);   // Display score
}

/* Capture function */
void captureEvent(Capture c) {
  c.read();
}