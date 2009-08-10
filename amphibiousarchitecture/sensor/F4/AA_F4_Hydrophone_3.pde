/* AA_F4_Hydrophone_3.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * configure mac, ip, and router/gw; set target ip and port; send udp string
 * kcw/theliving/2009.07.20
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

int analogPin = 4;

int volume = 0;
int count; 

// ETHERNET CONFIGURATION 
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = { 192, 168, 0, 3 };                      // sensor's IP address
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
  
  Serial.flush();
  
  volume = analogRead(analogPin);
  count++;
  Serial.print("count::::::::::::::: ");
  Serial.println(count);
  
  Serial.print("volume int: ");
  Serial.println(volume);

  char strVolume[4];
  itoa (volume, strVolume, 10);
  
  Serial.print("volume string: ");
  Serial.println(strVolume);

  // Strings hold the packets we want to send
  String asciiString = "action=f4&site=2&sensor=3&volume=";
  
  String otherString;

  otherString.append(asciiString); 
  otherString.append(strVolume); 

  UdpString.sendPacket(otherString,targetIp,targetPort);
  delay(2000);

}

/* end */
