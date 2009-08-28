#include <Firmata.h>

#include <WString.h>                // include the String library
#define maxLength 17
String inString = String(maxLength);       // allocate a new String
String DanceStr = String(maxLength);
String IDStr = String(maxLength);
String ID = String(2);
char *temp;
char *temp2;
char dance;
char dissox = '0';
char trackdissox = '0';
char event = '0';
int eventflip = 0;
int count;
int delayspeed = 20;

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
   0, 105, 205}; 


byte color[] = {
  GREEN[0], GREEN[1], GREEN[2]};
byte endcolor[] = {
  CYAN[0], CYAN[1], CYAN[2]};
byte eventColor[] = {
  OFF[0], OFF[1], OFF[2]};
byte returnColor[]= {
  OFF[0], OFF[1], OFF[2]};
;


void setup() {
  // open the serial port:
  Serial.begin(9600);

  for(int i = 0; i < 2; i++){
    pinMode(ledPinTop[i], OUTPUT);   
    pinMode(ledPinBot[i], OUTPUT);  
  }
  setColor(ledPinTop, OFF);       //Turn off led 1
  setColor(ledPinBot, OFF);       //Turn off led 2
  //DDRC = 0xff;
   DDRC = B00000;
  PORTC = B11111;
}

void loop () {

  // -----------------------------------< See if there's incoming serial data & if so load it into strings >
  if(Serial.available() > 0) {
    char inChar = Serial.read();

    if (inString.length() < 5) {
      inString.append(inChar);  
    } 
  }
  if (inString.charAt(4) != NULL){
    strncpy (IDStr,inString,2);
    dance = inString.charAt(2);
    dissox = inString.charAt(3);
    event = inString.charAt(4);
    Serial.write(inString);
    //Serial.println(inString);
  }

  // -----------------------------------< color top LED >
  if (event == '1'){
    eventflip = 1; 
  }

  if (eventflip > 0){
    delayspeed = 5;
    if (count == 0){
      returnColor[0] = color[0];
      returnColor[1] = color[1];
      returnColor[2] = color[2];
      eventColor[0]= OFF[0];
      eventColor[1]= OFF[1];
      eventColor[2]= OFF[2];
    }
    if(color[0] == OFF[0] && color[1] == OFF[1] && color[2] == OFF[2]){
      eventColor[0] = returnColor[0];
      eventColor[1] = returnColor[1];
      eventColor[2] = returnColor[2];
      if (eventflip == 1){
        eventflip = 2;
      }
      if (eventflip == 3){
        eventflip = 3;
      }
    }
    if (color[0] == returnColor[0] && color[1] == returnColor[1] && color[2] == returnColor[2] && eventflip == 2){
      eventColor[0]= OFF[0];
      eventColor[1]= OFF[1];
      eventColor[2]= OFF[2];
      eventflip = 3;
    }
    //setColor(ledPinTop, OFF); 
    int tempcolorEv0 = fadeToColor(color, eventColor, 0);
    int tempcolorEv1 = fadeToColor(color, eventColor, 1);
    int tempcolorEv2 = fadeToColor(color, eventColor, 2);
    color[0] =   tempcolorEv0; 
    color[1] =   tempcolorEv1; 
    color[2] =   tempcolorEv2; 
    setColor(ledPinTop, color);  
    count++;
    if(color[0] == returnColor[0] && color[1] == returnColor[1] && color[2] == returnColor[2] && eventflip == 3){
      eventflip = 0; 
      count = 0;
    }

  }

  else if (eventflip == 0){
    delayspeed = 20;
    // ---------------< FADE START >
    int tempcolor0 = fadeToColor(color, endcolor, 0);
    int tempcolor1 = fadeToColor(color, endcolor, 1);
    int tempcolor2 = fadeToColor(color, endcolor, 2);
    color[0] =   tempcolor0; 
    color[1] =   tempcolor1; 
    color[2] =   tempcolor2; 
    setColor(ledPinTop, color);  
    if(color[0] == endcolor[0] && color[1] == endcolor[1] && color[2] == endcolor[2]){
      endcolor[0] = flipColor (color, endcolor, dissox, trackdissox, 0);
      endcolor[1] = flipColor (color, endcolor, dissox, trackdissox, 1);
      endcolor[2] = flipColor (color, endcolor, dissox, trackdissox, 2);
      trackdissox == dissox;
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
    if (ID.length()<2){
    ID.append(IDtemp[0]);
      ID.append(IDtemp[1]); 
    }
  }


  // -----------------------------------< turn bottom one off due to fish >
  if (strcmp (ID,IDStr) == 0){

    if (dance == '1'){
      setColor(ledPinBot, color); 
    }
    else {
      setColor(ledPinBot, OFF); 
    }

  }



  // -----------------------------------< clear string >
  if (inString.length() == 5){
    inString = "";
  } 
  delay(delayspeed);  // -< use delay to control fade speed >
}






// -----------------------------------< functions that control light colors & fading >


void setColor(int* led, const byte* color){
  byte tempByte[] = {
    color[0], color[1], color[2]                                                                              };
  for(int i = 0; i < 3; i++){
    analogWrite(led[i], 255 - tempByte[i]);
  }
}




int fadeToColor(const byte* startColor, const byte* endColor, int j){
  byte tempByte1[] = {
    startColor[0], startColor[1]      , startColor[2]                                                                                                                                   };
  byte tempByte2[] = {
    endColor[0], endColor[1]    , endColor[2]                                                                                                                                      };
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
      endFC[0] = CYAN[0];
      endFC[1] = CYAN[1];
      endFC[2] = CYAN[2];
    }   
    if (startFC [0] == CYAN[0] && startFC [1] == CYAN[1] && startFC [2] == CYAN[2]){
      endFC[0] = GREEN[0];
      endFC[1] = GREEN[1];
      endFC[2] = GREEN[2];
    } 
    if (startFC [0] == PINK[0] && startFC [1] == PINK[1] && startFC [2] == PINK[2]){
      endFC[0] = CYAN [0];
      endFC[1] = CYAN [1];
      endFC[2] = CYAN [2];
    }
    if (startFC [0] == YELLOW[0] && startFC [1] == YELLOW[1] && startFC [2] == YELLOW[2]){
      endFC[0] = CYAN [0];
      endFC[1] = CYAN [1];
      endFC[2] = CYAN [2];
    }  
  }
  else if (dis == '1'){
    if (startFC [0] == PINK[0] && startFC [1] == PINK[1] && startFC [2] == PINK[2]){
      endFC[0] = YELLOW[0];
      endFC[1] = YELLOW[1];
      endFC[2] = YELLOW[2];
    }  
    if (startFC [0] == YELLOW[0] && startFC [1] == YELLOW[1] && startFC [2] == YELLOW[2]){
      endFC[0] = PINK[0];
      endFC[1] = PINK[1];
      endFC[2] = PINK[2];
    }  
    if (startFC [0] == CYAN[0] && startFC [1] == CYAN[1] && startFC [2] == CYAN[2]){
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



