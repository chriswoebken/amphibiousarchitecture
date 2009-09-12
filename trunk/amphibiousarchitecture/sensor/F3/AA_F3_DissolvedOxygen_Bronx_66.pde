/* AA_F3_DissolvedOxygen_Bronx_66.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * configure mac, ip, and router/gw; set target ip and port; send udp string
 * kcw/theliving/2009.07.20
 * cw/xclinic/2009.09.03
 * dar/theliving/209.09.12
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

#define maxLength 10
String inString = String(maxLength); 

char *data = "0";
char *temp2 = "0";
char *variable = "0";


// ETHERNET CONFIGURATION 
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xEC };   // MAC address to use
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

void loop() {

  if(Serial.available() > 0) {
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

  if (inString.contains("#") && inString.endsWith("!")) {
    char *p = inString;
    char *temp1 = strtok_r(p, "!", &p);
    temp2 = strtok_r(temp1, "=", &temp1);
    variable = strtok_r(temp2, "#", &temp2);
    data = strtok(temp1, "=");

    if (strcmp(variable, "DO") == 0) {
      String dissox = data;

      // send UDP string for DO -- send "dissox" which contains "data"

      // Strings hold the packets we want to send
      // site=1 is BRONX, site=2 is EAST
      String asciiString = "action=f3&site=1&sensor=66&dissox=";  // 34
      String otherString;

      otherString.append(asciiString);
      otherString.append(dissox);
      Serial.println(otherString);

      UdpString.sendPacket(otherString,targetIp,targetPort);
      otherString = "";
    }


    else if (strcmp(variable, "temp") == 0) {
      String temperature = data;

      // send UDP string for DO -- send "temperature" which contains "data"

      // Strings hold the packets we want to send
      String asciiString = "action=f3&site=2&sensor=66&temperature=";  // 34
      String otherString;

      otherString.append(asciiString);
      otherString.append(temperature);
      Serial.println(otherString);

      UdpString.sendPacket(otherString,targetIp,targetPort);
      otherString = "";
    }
  }

  inString = "";

}


/* the end */
