/* AA_InOutLightControl.pde
 * Processing 1.0.5, Mac Mini, D-Link router/switch, set of ethernet'd sensors
 * InOutControl has three goals: 1) receive senor inputs 2) process the inputs for light behavior 3) output behavior commands to the 16 tubes
 * ** UDP ** receive udp packets from sensors, parse the message, make message content available for light behavior, forward udp to boh
 * ** LED ** process the message for light behavior, send the behavior commands to the tubes
 * kcw/theliving/2009-07-20
 * dar/theliving/2009-08-06
 */

// -----------------------------------< initiate serial processing >
import processing.serial.*;
Serial port;

//define sensor variables
int event;

/****************************************************************************************** UDP ****/
/*
//import hypermedia.net.*;
 import processing.serial.*;
 UDP udp;
 */
int site = 0;       // these variable get filled in once a udp packet gets received and parsed
int sensor = 0;     // if any of them remain at zero and get sent to boh, then:
int volume = 0;     // sensor itself is reading a zero value, which should never happen
int dissox = 0;     // or there is a problem receiving udp packets from the sensors' ethernet
int nfish = 0;
int weight = 0;
int depth = 0;
/****************************************************************************************** END ****/


int fishexist;  // temporary feed
int count;
int fishnumber;
int oxygen;
int trackOxygen;
int flipOx;
int countDelay = 0;

// Fish Path variables
float AbeginX;
float AbeginY;
float endX = 570.0;   // Final x-coordinate
float endY = 320.0;   // Final y-coordinate
float AdistX;          // X-axis distance to move
float AdistY;          // Y-axis distance to move
float exponent = 3;   // Determines the curve
float xFishPath = 0.0;        // Current x-coordinate
float yFishPath = 0.0;        // Current y-coordinate
float step = 0.05;    // Size of each step along the path
float pct = 0.0;      // Percentage traveled (0.0 to 1.0)



// 2D Array of objects
ledFixture[][] levelTop;
ledFixture[][] levelBot;
char[][] trackledTop;
char[][] trackledBot;

//led constructor variables
int cols = 4;
int rows = 4;
int distbt = 150;
int cirsize = 30;
int start = 60;
int flip = 0;

int colorA = 0;
int colorB = 0;
int colorC = 0;
String d ;  //ID


// ---------------------------------------------------------< SET UP >
void setup() {

  port = new Serial(this, "COM17", 9600);  // -< serial setup >


  /***************************************************************************************** UDP ****/
  /*
  udp = new UDP( this, 6000 );                     // create a new datagram connection on port 6000
   udp.log( true );                                 // printout the connection activity
   udp.listen( true );                              // wait for incomming message
   
  /***************************************************************************************** END ****/



  // -----------------------------------< create display >
  size(600,600);
  levelTop = new ledFixture[cols][rows];
  levelBot = new ledFixture[cols][rows];
  trackledTop = new char [cols][rows];  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      // Initialize each object
      levelTop[i][j] = new ledFixture(i*distbt+start,j*distbt+start,cirsize,cirsize,colorA,i,j,d);
      levelBot[i][j] = new ledFixture(i*distbt+start,j*distbt+start+cirsize*2,cirsize,cirsize,colorC,i,j,d);
    }
  }
}




void draw() {
  background(0);
  if (countDelay == 0){
    delay(2000);
  }

  // -----------------------------------< generate random numbers for test >

  float f = random(0,200); // -< random number for fish >
  if (f > 150){
    fishexist= 1;
  }
  else if (f <= 150){
    fishexist = 0;
  }
  if (fishexist == 1){
    nfish = nfish+1;
  }

  // -----------------------------------< get variables ready for functions >
  fishnumber = nfish;
  if (dissox > 300 ){
    oxygen = 1;
  }
  if (dissox <= 300){
    oxygen = 0;
  }
  //oxygen = dissox;

  if (countDelay == 0){
    oxygen = 0;
  }

  // -----------------------------------< create a fish path if fish exists >
  if (count < (fishnumber) && pct == 0 ){
    // fish path setup
    AbeginX = 0;  
    AbeginY = random(10,590); 
    AdistX = endX - AbeginX;
    AdistY = endY - AbeginY;
    FishPath(AbeginX, AbeginY, AdistX, AdistY);
  }
  if (pct > 0){
    FishPath(AbeginX, AbeginY, AdistX, AdistY);
  }

  // -----------------------------------< generate display >
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      levelTop[i][j].display();
      levelBot[i][j].display();

      // -----------------------------------< perform function >
      // top led on, then fades if someone texts 
      if (event == 0 ){
        levelTop[i][j].on();
      }
      else if (event == 1){
        levelTop[i][j].circolor = 0;
      }

      //bottom led off, if fish detected create path and turn on due to proximity to path
      if (count != (fishnumber) || pct > 0 ){
        levelBot[i][j].FishRespond();
      }
      else {
        levelBot[i][j].circolor = 0;
      }

      // -----------------------------------< begin message to Arduino >
      levelTop[i][j].FindID();  // determine id based on grid
      char a ;  //ledFixture: top
      char c ;  //ledFixture: bottom
      char o;   //dissolved oxygen
      char e; // sms event

      if (levelTop[i][j].circolor == 0){ 
        a ='0';
      }
      else if (levelTop[i][j].circolor == 255){
        a ='1';
      }
      else {
        a ='0';
      }


      if (levelBot[i][j].circolor == 0){ 
        c ='0';
      }
      else if (levelBot[i][j].circolor == 255){
        c ='1';
      }
      else {
        c ='1';
      }


      if (oxygen == 1){
        o = '1';
      }
      else {
        o = '0';
      }


      if (event == 1){
        e = '1';
      }
      else {
        e = '0';
      }








      String[] strsend = { 
        levelTop[i][j].id , str(c), str(o) , str(e)                                          }; 
      String strDanceID = join(strsend,"");
      int send = int (strDanceID);

      if (trackOxygen != oxygen){
        flipOx = 1;
      }
      else{
        flipOx = 0; 
      }
      
      if (trackledTop[i][j] != c){
        println(strDanceID);
        port.write(strDanceID);
      }

      trackledTop[i][j] = c;
      delay (40);
    }
  }


  trackOxygen = oxygen;
  countDelay = countDelay+1;
  count = fishnumber; 
}



// A ledFixture object
class ledFixture {
  // A ledFixture object knows about its location in the grid as well as its size with the variables x,y,w,h.
  float x,y;   // x,y location
  float w,h;   // width and height
  int circolor; // color
  int fli; //getting brighter or getting dimmer
  int gridx,gridy;
  String id;

  // ledFixture Constructor
  ledFixture(float tempX, float tempY, float tempW, float tempH, int tempcolor, int tempgridx, int tempgridy, String d) {
    x = tempX;
    y = tempY;
    w = tempW;
    h = tempH;
    gridx = tempgridx;
    gridy = tempgridy;
    circolor = tempcolor;
    id = d;
  } 

  void display() {
    stroke(255);
    fill(0);
    ellipse(x,y,w,h);
  }


  void on (){
    circolor = 255;
    fill(circolor);
    ellipse(x,y,w,h);
  }

  void FishRespond(){
    float distance = dist(x, y, xFishPath, yFishPath);
    if (distance < 200){
      circolor = 255;
      fill(circolor);
      ellipse(x,y,w,h);

    }
  }


  void FindID(){

    if(gridx==0 && gridy==3){
      id="00";  
    }
    if(gridx==1 && gridy==3){
      id="01";  
    }
    if(gridx==2 && gridy==3){
      id="02";  
    }
    if(gridx==3 && gridy==3){
      id="03";  
    }
    if(gridx==0 && gridy==2){
      id="04";  
    }
    if(gridx==1 && gridy==2){
      id="05";  
    }
    if(gridx==2 && gridy==2){
      id="06";  
    }
    if(gridx==3 && gridy==2){
      id="07";  
    }
    if(gridx==0 && gridy==1){
      id="08";  
    }
    if(gridx==1 && gridy==1){
      id="09";  
    }
    if(gridx==2 && gridy==1){
      id="10";  
    }
    if(gridx==3 && gridy==1){
      id="11";  
    }
    if(gridx==0 && gridy==0){
      id="12";  
    }
    if(gridx==1 && gridy==0){
      id="13";  
    }
    if(gridx==2 && gridy==0){
      id="14";  
    }
    if(gridx==3 && gridy ==0){
      id="15";  
    }
  }
}



void FishPath(float beginX, float beginY,  float distX,  float distY){
  color c1Fish = color(255, 102, 0);

  if(pct == 0.0){
    beginX = xFishPath;
    beginY = yFishPath;
    float yRAN = random(10,590);
    endY = int(yRAN);
    endX = 600;
    distX = endX - beginX;
    distY = endY - beginY;
  }

  pct += step;
  if (pct < 1.0) {
    xFishPath = beginX + (pct * distX);
    yFishPath = beginY + (pow(pct, exponent) * distY);
  }
  fill(c1Fish);
  ellipse(xFishPath, yFishPath, 20, 20);

  if (pct > .9){
    pct = 0.0; 
  }

}




// -----------------------------------< manual input for variables >
void keyPressed() {
  if (key == 'c'){
    dissox = 200; //sending 0
  }
  if (key == 'w'){
    dissox = 400; //sending 1
  }
  if (key == 'e'){
    event = 1;
  }
  if (key == 'r'){
    event = 0;
  }
}






/****************************************************************************************** UDP ****/

/* ------------------------------------ for testing only -- */
/*
void keyPressed() {
 // String message  = str( key );                                  // the message to send
 String ip       = "92.243.23.29"; //"localhost";                  // the remote IP address
 int port        = 34567;                                          // the destination port
 
 String message = "action=f2&site=2&sensor=130&nfish=1";
 udp.send( message, ip, port );                                    // send the message
 
 if(message != null) {
 println("key pressed: " + message);
 }
 }
/* ------------------------------------------------- end -- */



/* ----------------------- do this when you get a packet -- */
/*
void receive( byte[] data, String ip, int port ) {                  // extended handler
 // void receive( byte[] data ) {                                  // default handler
 
 // data = subset(data, 0, data.length-1);
 String message = new String( data );
 
 
 
 /////////////////// send UDP to BOH ////
 String bohIP = "92.243.23.29";
 int bohPort  = 6000;
 udp.send( message, bohIP, bohPort );
 /////////////////////////////// end ////
 
 
 
 /////////////////// see the packets ////
 println( "receive: \""+message+"\" from "+ip+" on port "+port );
 
 String[] list = split(message, "&");                             // split 'message' at each "&"
 // put result in 'list'
 for(int i = 0; i < list.length; i++) {                           // iterate through all of 'list'
 String[] pair = split(list[i], "=");                           // split 'list' at each "="
 
 if (pair[0].equals("site")) {                                  // if parsed packet (pair[0]) equals tag word that we expect
 site = int(pair[1]);                                         // then set a variable equal to the following value (pair[1])
 }
 else if (pair[0].equals("sensor")) {                           // same as above
 sensor = int(pair[1]);                                       // do it for every tag word we expect to get
 }
 else if (pair[0].equals("volume")) {
 volume = int(pair[1]); 
 }
 else if (pair[0].equals("dissox")) {
 dissox = int(pair[1]); 
 }
 else if (pair[0].equals("nfish")) {
 nfish = int(pair[1]);
 }
 else if (pair[0].equals("weight")) {
 weight = int(pair[1]);
 }
 else if (pair[0].equals("depth")) {
 depth = int(pair[1]);
 }
 }
 
 println("volume = " + volume);                                   // monitor how the packet values change
 println("dissox = " + dissox);
 println("nfish = " + nfish);
 println();
 /////////////////////////////// end ////
 }
 */
/* ------------------------------------------------- end -- */
/****************************************************************************************** END ****/












