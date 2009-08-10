/* AA_F2_Sonar_130.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * configure mac, ip, and router/gw; set target ip and port; send udp string
 * kcw/theliving/2009.07.20
 * cw/xclinic/2009.08.06
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

int nfish;
int count;

int left = 8;  
int middle = 9;
int right = 10;

// ETHERNET CONFIGURATION 
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = { 192, 168, 0, 130 };                      // sensor's IP address
byte gw[] = { 192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = { 192, 168, 0, 2};
int targetPort = 6000;

void setup() {
  Serial.begin(9600);

  /******************************** simulate button press ****/
  pinMode(left, OUTPUT);
  pinMode(middle, OUTPUT); 
  pinMode(right, OUTPUT);
  digitalWrite(middle, HIGH); 
  delay(1000);  
  digitalWrite(middle, LOW);  
  delay(1000);    
  digitalWrite(left, HIGH); 
  delay(3000);  
  digitalWrite(left, LOW);  
  delay(1000);   
  digitalWrite(left, HIGH); 
  delay(1000);
  digitalWrite(left, LOW);  
  delay(1000);
  digitalWrite(left, HIGH); 
  delay(1000);
  digitalWrite(left, LOW);  
  delay(1000); 
  digitalWrite(right, HIGH); 
  delay(1000);  
  digitalWrite(right, LOW);  
  delay(4000);   
  /************************************************* end ****/

  Ethernet.begin(mac,ip,gw);
  UdpString.begin(localPort);

}

void loop() {

  Serial.flush();
  
  nfish = analogRead(analogPin);
  count++;
  Serial.print("count::::::::::::::: ");
  Serial.println(count);
  
  Serial.print("nfish int: ");
  Serial.println(nfish);

  char strNfish[4];
  itoa (nfish, strNfish, 10);
  
  Serial.print("nfish string: ");
  Serial.println(strNfish);

  // Strings hold the packets we want to send
  String asciiString = "action=f2&site=2&sensor=130&nfish=";  // 34

  String otherString;

  otherString.append(asciiString); 
  otherString.append(strNfish); 

  UdpString.sendPacket(otherString,targetIp,targetPort); 
  delay(2000);
  
  Serial.print("sendPacket: ");
  Serial.println(otherString);

}

/* end */
