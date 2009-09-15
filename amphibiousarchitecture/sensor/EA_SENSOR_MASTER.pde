/* EA_SENSOR_MASTER.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * receive UDP formatted messages via rs485 from DOTEMP and SONAR, 
 * check that the message is good (checksum, frame check),
 * send error UDP packets to macmini, or send good packets to macmini
 * kcw/theliving/2009.09.12
 * jcl/theliving/2009.09.12
 *
 * LIBRARIES REQUIRED:
 * Ethernet: http://arduino.cc/en/Reference/Ethernet
 * UDP String: http://bitbucket.org/bjoern/arduino_osc/src/tip/libraries/Ethernet/
 * WString: http://wiring.org.co/learning/reference/String.html
 *** must include the following within the String library file WString.h:
 String(const int length = 16);
 String(const char* bytes);
 String(const String &str);
 ~String() { free(_array); } // <--- add this line  
 *** adding this line "destructs" the string after each use.  without it, the loop will evetually stop.
 *** read the forum about it: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1231346812
 */

#include <Ethernet.h>
#include <UdpString.h>
#include <WString.h>

#define maxLength 100
String inString = String(maxLength); 


// ETHERNET CONFIGURATION 
byte mac[] = { 0x40, 0x61, 0x61, 0x30, 0x30, 0x31 };   // MAC address to use @AA001
byte ip[] = { 192, 168, 0, 66 };                       // sensor's IP address
byte gw[] = { 192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = { 192, 168, 0, 2};
int targetPort = 6000;

void setup() {
  Serial.begin(9600);

  Ethernet.begin(mac,ip,gw);
  UdpString.begin(localPort);

}

byte htoi(char *s) {                    // hex things for the checksum - jcl
  byte x;
  char c;
  x = 0;
  while ((c = toupper(*s)) != '\0') {
    if ((c >= '0') && (c <= '9')) {
      x = (x * 16) + (c - '0');
    } else if ((c >= 'A') && (c <= 'F')) {
      x = (x * 16) + ((c - 'A') + 10);
    } else {
      // give up on with the non-hex char
      break;
    }
    ++s;
  }
  return(x);
}

void loop() {
  int c;

  // incoming serial should be a framed string eg '#name=valuesum!'
  for (;;) {
    // waiting for frame start
    c = Serial.read();
    if (c == '#') {
      break;
    }
  }
  // seen the frame start  

  // read to frame end
  inString = "";
  for (;;) {                          // for forever
    c = Serial.read();                // read the serial
    if (c == -1) {                    // if there's no signal, jump back to start of for loop
     // Serial.println("dribble1");
      continue;

    }
    if (c == '#') {                   // if the serial read is #, then clear string and jump to start of for loop
      inString = "";
      // Serial.println("dribble2");
      continue;
    }
    if (c == '!') {                   // if the serial read is !, then exit the for loop, this is end of message so we don't append to inString
      break;
    }

    // if too big just throw it away
    if (inString.length() == maxLength-1) {
      inString = "";
      // Serial.println("dribble3");
      continue;
    }

    // keep the character
    inString.append((char)c);
    // Serial.println(inString);
  }

  // now we have the string with the sum at the end
  // remove cs as 'txsum'
  String txsumString = inString.substring(inString.length()-2, inString.length());
  byte txsum;
  txsum = htoi(txsumString);

 // Serial.println((int)txsum);

  // do length check here
  if (inString.length() < 2) {          // if the message is less than 2, ie less than an empty string with only a checksum
    String goodString = "runt=1";
   // Serial.println("im iz runt");
    UdpString.sendPacket(goodString,targetIp,targetPort);
    goodString = "";
    return;
  }

  String goodString = inString.substring(0, inString.length()-2);


  // Serial.println(goodString);
  // calculate the checksum ourselves
  byte csum = 255;
  int i;
  for ( i = 0;  i < goodString.length();  ++i) {   // checksum applies only to the goodString, not inString
    // Serial.println(i);
    csum *= 2;                                     // multiply csum by 2 to eliminate conflict, ie "abc" and "acb"
    csum += goodString.charAt(i);                  // add charAt(i) to itself for less than goodString.length
    // Serial.println((int)csum);
  }

  // check the check sum
  if (csum != txsum) {
    goodString = "csumerror=1";
    UdpString.sendPacket(goodString,targetIp,targetPort);
    goodString = "";
    return;
  }

  // Serial.println(goodString);
  UdpString.sendPacket(inString,targetIp,targetPort);
  goodString = "";
  inString = "";

}

/* the end */
