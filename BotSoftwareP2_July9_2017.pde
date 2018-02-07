

// Key 1 = 0,0
// Key 2 = width,0
// Key 3 = width,height
// Key 4 = 0,height
// Key S = stop
// Key G = go

LineToGo toGoArray;
Bot Machine;
//OutputImage Photo;

import processing.serial.*;  // serial communication
import java.io.*; //Java
import geomerative.*; // svg parsing

//---------------------------------------------------
//Change these if you want.

int multiplier = 1; // size multiplication
boolean doSave=true;
boolean timelapse = true;
boolean servoOn = true;  // draw with the servo control or not.
boolean serialOn = true; //TURN SERIAL ON WITH 1 OFF WITH ANYTHING ELSE
boolean printArray = false;
boolean autoStop = true;
boolean On = false;// USED SO THAT THE KEY 'S' AND 'G' START AND STOP THE DRAWING SEQUENCE, starts off to calibrate

// current size = 1350 x 2100 - should be same as int x and int y in the firmware
int StepUnit = 82;
long xofset = 18*StepUnit; // Ofset of x from left top corner
long yofset = 40*StepUnit; // Ofset of y from left top corner

//---------------------------------------------------


PVector Current;
PVector lastOld;

boolean jumpFlag = true;
boolean atPoint = true; // if the arduino returns that it is at the point, turn true.


RShape grp;
RPoint[][] pointPaths;
int j = 0;
int i = 0;

void setup() {




 // Photo = new OutputImage();

  //----------------------------------------------------------------------------------
//paper size 70 x 100cm
//27 inches x 40inches
  size(30, 30);  //illustrator pixel size 8000 x 10500
  // y = 14 inches
// 1 inch = 150px
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);
  grp = RG.loadShape("BristolFromPigment_4200x5460.svg");
  grp.centerIn(g, 0, 0, 0);
  pointPaths = grp.getPointsInPaths();

  //----------------------------------------------------------------------------------
  background(255);


  toGoArray = new LineToGo(); //start the array line
  Machine = new Bot(this);

  Current = new  PVector(0, 0, 0);
  lastOld = new PVector(0, 0);
}//void setup


void keyPressed() {
  if (key == 'a') {
    atPoint =true;
  }
  if (key == 'g') {    // g key will start the movement.
    On = true;
    autoStop = true;
  }  
  if (key == 's') {    //s key will stop the movement
    autoStop = false;
    On = false;
  }
  if (key == ' ') {
    background(255);
  }

  if (!On) {
    switch(key) {
    case '1':
      Machine.sendVal(0, 0, 0); //move to the top left corner of the drawing area
      break;
    case '2':
      Machine.sendVal(width, 0, 0); //move to the top right corner of the drawing area
      break;
    case '3':
      Machine.sendVal(width, height, 0);  //move to the bottom right corner of the drawing area
      break;
    case '4':
      Machine.sendVal(0, height, 0); //move to the bottom left corner of the drawing area
      break;
    } //switch 1-4 keys
    if ((key == ',')||(key == '.')||(key == '<')||(key == '>')||(key == '-')||(key == '+')) {
      Machine.DirectCommand(str(key));
    } // matches a correct command
  } // not on;
} //end keyPressed

void draw() {
  
 
  
  Machine.update(); //checks for new point reached
  toGoArray.update(); // check for atPoint, and send new value



    if (On) {
    PVector out = new PVector(-width/2, -height/2);
    //----------------------------
   // println("out.x = " + out.x + "out.y = " + out.y);
    translate(0, 0);

    if (i == pointPaths.length) {
      Machine.DirectCommand("-");
      On = false;
      println("!!!!!!!!!EOF!!!!!!!!!!!");
    }

    if (pointPaths[i] == null) { // if there is no points in path, advance up one
      i++;
    }
    if (pointPaths[i] != null) { 

      if (i < pointPaths.length) { // count through each path i = current path
        println("point#:  " + j + " / " + pointPaths[i].length); 
        println("path#:   " + i + "/ " +  pointPaths.length);



        if (j < pointPaths[i].length) {  // count through each point in path 



            Current.set(pointPaths[i][j].x, pointPaths[i][j].y, 1);




/*
          print("real xy : ");
          print(Current.x + "," + Current.y);

          print("point at:  ");
          print (Current.x + width/2 + out.x);
          print(',');
          println(Current.x + height/2 + out.y);
          println("_________________________");

*/


          if (jumpFlag) {
            Current.z = 0;
            jumpFlag = false;
          }
          toGoArray.addToArray(Current.x + width/2 + out.x, Current.y +height/2 + out.y, Current.z); // add a new point to the array
          //Photo.addCount(); // adds a count to the save counter and total found points




          j++; //advance to next point in path
        } // each point in path 



        if (j == pointPaths[i].length) {  // if j has reached the last point in path i
          j = 0; //reset j for next path
          jumpFlag = true; //lift pen
          i++; //advance to next path
          //println("moved to next path");
        } // at last point in path
      } // end drawing paths
    }//path had points
  }//onOff
} //draw



