/* EA_SENSOR_DOTEMP.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * read soft serial from jordan board, build udp formatted message, 
 * append checksum value, transmit over rs485 to sensor master
 * cw/xclinic/2009.09.03
 * dar/theliving/2009.09.11
 * kcw/theliving/2009.09.12
 * jcl/xclinic/2009.09.12
 *
 * LIBRARIES REQUIRED:
 * WString: http://wiring.org.co/learning/reference/String.html
 *** must include the following within the String library file WString.h:
 String(const int length = 16);
 String(const char* bytes);
 String(const String &str);
 ~String() { free(_array); } // <--- add this line  
 *** adding this line "destructs" the string after each use.  without it, the loop will evetually stop.
 *** read the forum about it: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1231346812
 */


#include <WString.h>
#include <NewSoftSerial.h>

#define maxLength 100
String inString = String(maxLength);       // allocate a new String
char* myStrings[5];
char turnon[3] = "DO";
byte CR = 13;
int incomingByte = 0;
char* sendTemp;

NewSoftSerial mySerial(2, 3);              // SOFWARE SERIAL CONFIGURATION (Rx, Tx)


void setup() {
  Serial.begin(9600);
  mySerial.begin(9600);
  pinMode(6, OUTPUT);
}


// input x is 0 to 15 incl, output is hex character for that
char hexchar(byte x) {                                            // !!!!!!!!!! is this 'hexval' or 'hexchar'? i changed it from hexval to hexchar
  x &= 0x0f;
  if ((x >= 0) && (x <= 9)) {
    return(x + '0');
  } 
  else {
    return(x + ('A' - 10));
  }
}


void loop() {
  DO();
  delay(4000);

  if (mySerial.available() > 0) {
    while (inString.length() < maxLength){
      incomingByte = mySerial.read();
      char data = char (incomingByte);
      delay (10);
      inString.append(data); 
    }
  }

  if (inString.charAt(0) == 'D'){
    char *p = inString;
    for (int j = 0; j <4; j++){ 
      myStrings[j] =  strtok_r(p, "%", &p);                             // myStrings[j] =  strtok_r(p, "°", &p);
    }
    char *tempBreak = strtok_r(myStrings[0], "=", &myStrings[0]);       // tempBreak == DO  --> splitting string at "=" 
    char *tempBreaknoDec = strtok_r(myStrings[0], ".", &myStrings[0]);  // tempBreaknoDec == (DO integer)  --> splitting string at "."
    sendTemp = (tempBreaknoDec);





    // BUILD UDP FORMATTED MESSAGE (see 'System Overview' on nyu wiki)
    String delimiter = "&";

    String action = "action=f3";      // we know this because inString.charAt(0) == 'D'
    String site = "site=2";           // should we put bronx/east site id inside address selector?
    String sensor = "sensor=0";       // only needed if we have more than one f3/dissox sensor per site?
    String dissox = "dissox=";        // no value because we'll add sendTemp to it
    String checksum = "csum=";
    String sendFinal = String(maxLength);                 // we'll put everything in here and send this

    strcpy(sendFinal, action);        // put action into sendFinal, put ampersand
    strcat(sendFinal, delimiter);

    strcat(sendFinal, site);          // put site into sendFinal, put ampersand
    strcat(sendFinal, delimiter);

    strcat(sendFinal, sensor);        // put sensor into sendFinal, put ampersand
    strcat(sendFinal, delimiter);

    strcat(sendFinal, dissox);        // put dissox=, put realtime dissox value sendTemp, put ampersand
    strcat(sendFinal, sendTemp);
    strcat(sendFinal, delimiter);
    
    strcat(sendFinal, checksum);
    
   
    // sendFinal is fully loaded...
    
    
    // work out checkum
    byte csum;
    csum = 255;
    for (int i = 0;  i < strlen(sendFinal);  ++i) {
      csum *= 2;
      csum += sendFinal.getBytes()[i];    // horrible ugly avoiding sendFinal.charAt(i)
    }
   
    // WRITE UDP FORMATTED MESSAGE (one message component at a time)
    digitalWrite(6, HIGH);
    
    Serial.write("#");                          // 1) frame start
    Serial.write (sendFinal);                   // 2) udp formatted message
    Serial.print(hexchar(csum >> 4), BYTE);     // 3) first character of the checksum
    Serial.print(hexchar(csum & 0x0f), BYTE);   // 4) second character of the checksum
    Serial.write("!");                          // 5) frame end
    Serial.println();
 //   delay(2000);
    digitalWrite(6, LOW);
    delay(6000);
    
    sendFinal = "";

  }

  inString = "";

}


void DO() {                          // activate the jordan board!
  mySerial.print(turnon);
  mySerial.print(CR);
 // delay(100);
 // Serial.print("DO");
 // delay(100);
 // mySerial.print(CR);
}

/* the end */



