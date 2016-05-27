class Bubble {
  int bubbleX, bubbleY, bubbleWidth, bubbleHeight;  //  Variables to hold the bubble's coordinates and width/height
 
  Bubble ( int bX, int bY, int bW, int bH )  //  Class constructor- sets all the values when a new bubble object is created
  {
    bubbleX = bX;
    bubbleY = bY;
    bubbleWidth = bW;
    bubbleHeight = bH;
  }
 
  int update()      //   The Bubble update function
  {
    int movementAmount;          //  Create and set a variable to hold the amount of white pixels detected in the area where the bubble is
    movementAmount = 0;
    for( int y = bubbleY; y < (bubbleY + (bubbleHeight-1)); y++ ){   //  For loop that cycles through all of the pixels in the area the bubble occupies
      for( int x = bubbleX; x < (bubbleX + (bubbleWidth-1)); x++ ){
        if ( x< width && x > 0 && y < height && y > 0 ){             //  If the current pixel is within the screen bondaries
          if (brightness(diff.pixels[x + (y * width)]) > 127)        //  and if the brightness is above 127 (in this case, if it is white)
          {
            movementAmount++;                                        //  Add 1 to the movementAmount variable.
          }
        }
      }
    }
     
    if (movementAmount > 5)               //  If more than 5 pixels of movement are detected in the bubble area
    {
      poppedBubbles++;                    //  Add 1 to the variable that holds the number of popped bubbles
      return 1;                           //  Return 1 so that the bubble object is destroyed 
    }else{                                //  If less than 5 pixels of movement are detected,
      bubbleY += 10;                      //  increase the y position of the bubble so that it falls down
      if (bubbleY > height)               //  If the bubble has dropped off of the bottom of the screen
      {  
        return 1;                         //  Return '1' so that the bubble object is destroyed
      }                      
      image(bubblePNG, bubbleX, bubbleY); //  Draws the bubble to the screen
            return 0;                     //  Returns '0' so that the bubble isn't destroyed
    }
  }
}