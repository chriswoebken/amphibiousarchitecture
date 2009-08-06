/* AA_F4_Hydrophone_3.pde
 * Arduino 0016 with Arduino 2009 and Arduino Ethernet Shield
 * configure mac, ip, and router/gw; set target ip and port; send udp string
 * kcw/theliving/2009.07.20
 * cwo/xClinic/2009.08.06
 */

#include <Ethernet.h>
#include <UdpString.h>
#include <WString.h>

int analogPin = 4;
int volume = 0;
  char str[30];
  int count; 
int left = 8;  
int middle = 9;
int right = 10;

// ETHERNET CONFIGURATION 
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = { 192, 168, 0, 3 };                      // Arduino's IP address
byte gw[] = { 192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = { 192, 168, 0, 2};
int targetPort = 6000;

// Strings hold the packets we want to send
String asciiString;


void setup() {
  Serial.begin(9600);
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
  
  DDRC = 0xff;
  int nodeID = PINC;
  
  Ethernet.begin(mac,ip,gw);
  UdpString.begin(localPort);
  
}

void loop() {
  
  volume = analogRead(analogPin);
  count++;

  char strVolume[4];
  itoa (volume, strVolume, 10);

  asciiString = "action=f4&site=2&sensor=3&volume=";

  strcpy (str, asciiString);
  strcat (str, strVolume);
 // Serial.println(str);
 
  // send a normal, zero-terminated string.
  String asciiString1 = str;
 UdpString.sendPacket(asciiString1,targetIp,targetPort);
  delay(2000);

  /*
  // sends a binary string that can contain 0x00 in the middle
   // you have to specify the length;
   UdpString.sendPacket(binaryString,binaryString.capacity(),targetIp,targetPort);
   delay(1000);
   */
}

/* end */
