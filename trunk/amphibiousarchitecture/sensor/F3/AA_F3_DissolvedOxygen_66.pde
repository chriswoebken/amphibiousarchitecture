 /* AA_F3_DissolvedOxygen_66.pde
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

#define maxLength 15
String inString = String(maxLength);       // allocate a new String
String finalStr = String(maxLength);       // allocate a new String

char* myStrings[5];
char *temperature [2];

int analogPin = 0;
char strDissox[4];
char turnon[3] = "TF";
byte CR = 13;
char receive[10];
int incomingByte = 0;
char* sendTemp;


int dissox;
int count;

// ETHERNET CONFIGURATION 
byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = { 
  192, 168, 0, 66 };                       // sensor's IP address
byte gw[] = { 
  192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = { 
  192, 168, 0, 2};
int targetPort = 6000;

void setup() {
  Serial.begin(9600);

  Ethernet.begin(mac,ip,gw);
  // UdpString.begin(localPort);

}

void loop() {

  Serial.flush();




  TF();
  delay(4000);
  if (Serial.available() > 0) {
    while (inString.length() < maxLength){
      incomingByte = Serial.read();
      char data = char (incomingByte);
      //Serial.print(data);
      delay (10);
      inString.append(data); 
    } 
  }

  if (inString.charAt(0) == 'T'){

    char *p = inString;
    for (int j = 0; j <4; j++){
      myStrings[j] =  strtok_r(p, "�", &p);
    }
    char *tempBreak = strtok_r(myStrings[0], "=", &myStrings[0]);


    sendTemp = (myStrings[0]);

    String asciiString = "action=f3&site=2&sensor=66&dissox=";  // 34
    String otherString;

    otherString.append(asciiString); 
    otherString.append(sendTemp);
    Serial.print("     "); 
    Serial.print(otherString);
    Serial.print("     ");

   UdpString.sendPacket(otherString,targetIp,targetPort);
   delay(2000);

  }


 
   //count++;   
   //  Serial.print("count::::::::::::::: ");
   //  Serial.println(count);   
   //  Serial.print("dissox int: ");
   //  Serial.println(dissox);   
   //  char strDissox[4];
   //  itoa (dissox, strDissox, 10);   
   //  Serial.print("dissox string: ");
   //  Serial.println(strDissox);
   // Strings hold the packets we want to send 
   
   // UdpString.sendPacket(otherString,targetIp,targetPort);
   // delay(2000);
   
   //  Serial.print("sendPacket: ");
   //  Serial.println(otherString);



  inString = "";
  finalStr = "";

}



void TF() {
  Serial.write(turnon);
  Serial.write(CR); 
}

/* end */
