#include <Firmata.h>

#include <WString.h>                // include the String library
#define maxLength 30
String inString = String(maxLength);       // allocate a new String
String DanceStr = String(maxLength);
String IDStr = String(maxLength);
String ID = String(2);
String IDincoming = String(2);
char *temp;
char *temp2;
char trackdissox = '0';

char ox;
char* myStrings[5];
char *IDnow ;
char *dissox = "0";
char *event = "0";
char *dance ;

int ledPinTop[] = {
  3, 5,6}; //3-red,5-blue,6-green
int ledPinBot[] = {
  9, 10,11}; //9-red,10-blue,11-green
const byte RED[] = {
  0, 255, 255}; 
const byte ORANGE[] = {
  172, 255, 251}; 
const byte YELLOW[] = {
  0, 255, 0}; 
const byte GREEN[] = {
  255, 255, 0}; 
const byte BLUE[] = {
  255, 0, 255}; 
const byte INDIGO[] = {
  251, 236, 255}; 
const byte VIOLET[] = {
  232, 233, 255}; 
const byte CYAN[] = {
  255, 0, 0}; 
const byte MAGENTA[] = {
  0, 0, 255}; 
const byte OFF[] = {
  255, 255, 255}; 
const byte WHITE[] = {
  0, 0, 0}; 
const byte PINK[] = {
  97, 176, 251}; 


byte color[] = {
  GREEN[0], GREEN[1], GREEN[2]};
byte endcolor[] = {
  BLUE[0], BLUE[1], BLUE[2]};


void setup() {
  // open the serial port:
  Serial.begin(9600);

  for(int i = 0; i < 2; i++){
    pinMode(ledPinTop[i], OUTPUT);   
    pinMode(ledPinBot[i], OUTPUT);  
  }
  setColor(ledPinTop, OFF);       //Turn off led 1
  setColor(ledPinBot, OFF);       //Turn off led 2
  DDRC = 0xff;
}

void loop () {

  // -----------------------------------< See if there's incoming serial data & if so load it into strings >
  if(Serial.available() > 0) {  //ID=06;ox=0;ev=0;dc=0;A!
    while (inString.length() < maxLength){
      char inChar = Serial.read();
      if (inChar==NULL){
        break; 
      }
      delay (10);
      inString.append(inChar); 
      if (inChar == '!'){
        break; 
      }
    } 
  }

  if (inString.charAt(15) != NULL){
    char *p = inString;

    for (int j = 0; j <4; j++){
      myStrings[j] =  strtok_r(p, ";", &p);
      if (*myStrings[j] == 'A'){
        //Serial.println("break");
        break;
      }
    }

    char *temp = strtok_r(myStrings[0], "=", &myStrings[0]);
    IDnow = strtok(myStrings[0], "=");
    temp = strtok_r(myStrings[1], "=", &myStrings[1]);
    dissox = strtok(myStrings[1], "=");
    temp = strtok_r(myStrings[2], "=", &myStrings[2]);
    event = strtok(myStrings[2], "=");
    temp = strtok_r(myStrings[3], "=", &myStrings[3]);
    dance = strtok(myStrings[3], "=");
/*
    Serial.print ("ID= ");
    Serial.println (IDnow);
    Serial.print ("dissox= ");
    Serial.println (dissox);
    Serial.print ("event= ");
    Serial.println (event);
    Serial.print ("dance= ");
    Serial.println (dance);
*/

    if (IDincoming.length()<3){
      IDincoming.append(IDnow[0]);
      if (IDnow[1] != NULL){
        IDincoming.append(IDnow[1]);
      }
    }
  }

  // -----------------------------------< color top LED >
  if (*event == '1'){
    setColor(ledPinTop, OFF); 
  }
  else{
    if (*dissox != NULL){
   ox = *dissox;
    //Serial.print ("change dissox to: ");
   // Serial.println (ox);
    }
    
    // ---------------< FADE START >
    int tempcolor0 = fadeToColor(color, endcolor, 0);
    int tempcolor1 = fadeToColor(color, endcolor, 1);
    int tempcolor2 = fadeToColor(color, endcolor, 2);
    color[0] =   tempcolor0; 
    color[1] =   tempcolor1; 
    color[2] =   tempcolor2; 
    setColor(ledPinTop, color);  
    if(color[0] == endcolor[0] && color[1] == endcolor[1] && color[2] == endcolor[2]){
      endcolor[0] = flipColor (color, endcolor, ox, trackdissox, 0);
      endcolor[1] = flipColor (color, endcolor, ox, trackdissox, 1);
      endcolor[2] = flipColor (color, endcolor, ox, trackdissox, 2);
      trackdissox == ox;
    }
    // ---------------< FADE END >

  }




  // -----------------------------------< check ID >
  int nodeID = PINC;
  char IDtemp[2];
  itoa(nodeID, IDtemp, 10);

  if (nodeID < 10){
    if (ID.length()<2){
      ID.append('0');
      ID.append(IDtemp[0]);  
    }
  }

  else {
    ID[0] = IDtemp[0];
    ID[1] = IDtemp[1];    
  }


  // -----------------------------------< turn bottom one off due to fish >
  if (strcmp (ID,IDincoming) == 0){

if (*dance != NULL){
    if (*dance == '1'){
      //Serial.println ("and were in");
      setColor(ledPinBot, color); 
    }
    else if (*dance == '0'){
      //Serial.println ("OFF");
      setColor(ledPinBot, OFF); 
    }

  }
  }



  // -----------------------------------< clear string >


  IDincoming = "";
  inString = "";
  delay(20);  // -< use delay to control fade speed >
}






// -----------------------------------< functions that control light colors & fading >


void setColor(int* led, const byte* color){
  byte tempByte[] = {
    color[0], color[1], color[2]                                                                          };
  for(int i = 0; i < 3; i++){
    analogWrite(led[i], 255 - tempByte[i]);
  }
}




int fadeToColor(const byte* startColor, const byte* endColor, int j){
  byte tempByte1[] = {
    startColor[0], startColor[1]      , startColor[2]                                                                                                                               };
  byte tempByte2[] = {
    endColor[0], endColor[1]    , endColor[2]                                                                                                                                  };
  byte* startColor2 = tempByte1;
  byte* endColor2 = tempByte2;

  int changeRed = endColor2[0] - startColor2[0];                            //the difference in the two colors for the red channel
  int changeGreen = endColor2[1] - startColor2[1];                          //the difference in the two colors for the green channel 
  int changeBlue = endColor2[2] - startColor2[2];                            //the difference in the two colors for the red channel
  //the difference in the two colors for the blue channel
  int steps = max(abs(changeRed),max(abs(changeGreen), abs(changeBlue))); //make the number of change steps the maximum channel change
  //int i=0;

  //for(int i = 0 ; i < steps; i++){                                        //iterate for the channel with the maximum change
  byte newRed = startColor2[0] + (1 * changeRed / steps);                 //the newRed intensity dependant on the start intensity and the change determined above
  byte newGreen = startColor2[1] +(1 * changeGreen / steps);             //the newGreen intensity
  byte newBlue = startColor2[2] +(1 * changeBlue / steps);            //the newBlue intensity
  byte newColor[] = {
    newRed, newGreen , newBlue                   //Define an RGB color array for the new color                              
  };                         

  return newColor[j];
}



int flipColor(byte* startFC, byte* endFC, char dis, char trackdis, int k){
  if (dis == '0'){
    if (startFC [0] == GREEN[0] && startFC [1] == GREEN[1] && startFC [2] == GREEN[2]){
      endFC[0] = BLUE[0];
      endFC[1] = BLUE[1];
      endFC[2] = BLUE[2];
    }   
    if (startFC [0] == BLUE[0] && startFC [1] == BLUE[1] && startFC [2] == BLUE[2]){
      endFC[0] = GREEN[0];
      endFC[1] = GREEN[1];
      endFC[2] = GREEN[2];
    } 
    if (startFC [0] == RED[0] && startFC [1] == RED[1] && startFC [2] == RED[2]){
      endFC[0] = BLUE [0];
      endFC[1] = BLUE [1];
      endFC[2] = BLUE [2];
    }
    if (startFC [0] == YELLOW[0] && startFC [1] == YELLOW[1] && startFC [2] == YELLOW[2]){
      endFC[0] = BLUE [0];
      endFC[1] = BLUE [1];
      endFC[2] = BLUE [2];
    }  
  }
  else if (dis == '1'){
    if (startFC [0] == RED[0] && startFC [1] == RED[1] && startFC [2] == RED[2]){
      endFC[0] = YELLOW[0];
      endFC[1] = YELLOW[1];
      endFC[2] = YELLOW[2];
    }  
    if (startFC [0] == YELLOW[0] && startFC [1] == YELLOW[1] && startFC [2] == YELLOW[2]){
      endFC[0] = RED[0];
      endFC[1] = RED[1];
      endFC[2] = RED[2];
    }  
    if (startFC [0] == BLUE[0] && startFC [1] == BLUE[1] && startFC [2] == BLUE[2]){
      endFC[0] = YELLOW [0];
      endFC[1] = YELLOW [1];
      endFC[2] = YELLOW [2];   
    }
    if (startFC [0] == GREEN[0] && startFC [1] == GREEN[1] && startFC [2] == GREEN[2]){
      endFC[0] = YELLOW [0];
      endFC[1] = YELLOW [1];
      endFC[2] = YELLOW [2];   
    }
  }


  return endFC[k];
}



