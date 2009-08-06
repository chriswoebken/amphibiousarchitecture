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

/*
  byte color[] = {
 RED[0], RED[1], RED[2]};
 byte endcolor[] = {
 YELLOW[0], YELLOW[1], YELLOW[2]};
 */

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
  if(Serial.available() > 0) {
    char inChar = Serial.read();
    //Serial.write(inChar);
    if (inString.length() < 4) {
      inString.append(inChar);  
    } 
  }
  if (inString.charAt(3) != NULL){
    strncpy (IDStr,inString,2);
    dance = inString.charAt(2);
    dissox = inString.charAt(3);
    Serial.write(inString);
  }

if (dissox == '1'){
     setColor(ledPinTop, RED); 
    }
    else if (dissox == '0'){
      setColor(ledPinTop, OFF); 
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
  if (strcmp (ID,IDStr) == 0){

    if (dance == '1'){
      setColor(ledPinBot, MAGENTA); 
    }
    else {
      setColor(ledPinBot, OFF); 
    }
    
  }



  // -----------------------------------< clear string >
  if (inString.length() == 4){
    inString = "";
  } 
  delay(20);  // -< use delay to control fade speed >
}






// -----------------------------------< functions that control light colors & fading >


void setColor(int* led, const byte* color){
  byte tempByte[] = {
    color[0], color[1], color[2]                                                                    };
  for(int i = 0; i < 3; i++){
    analogWrite(led[i], 255 - tempByte[i]);
  }
}





