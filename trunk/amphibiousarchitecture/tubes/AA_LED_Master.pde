/* AA_LED_Master.pde
 * Arduino 0016 with Arduino 2009 and RS485
 * receive UDP packet from ethernetsent from mini, repackage it for LED short format,
 * send it over rs485 via serial.write().
 * kcw/theliving/2009.07.20
 * ak/xclinic/2009.09.11
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
 *** adding this line "destructs" the string after each use.  without
 it, the loop will evetually stop.
 *** read the forum about it:
 http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1231346812
 */


#include <Ethernet.h>
#include <UdpString.h>
#include <WString.h> 

#define maxLength 64 //25          // #action=f1&site=2&dissox=9006&event=1&fishon=1&id=06&end

// allocate a new String
String inString = String(maxLength);   


char *myStrings[5];
char *nextString[10];
char *new_data[5];
char *temp;

char *dissox = "0";
char *id = "0";
char *event = "0";
char *action = "0";
char *site = "0";
char *fishon = "0";


/*int dissox = 0;
 int id = 0;
 char *event = "0";
 char *action = "0";
 char *site = "0";
 char *fishon = "0";
 */

String IDincoming = String(2);

String packet(32); //packet can be max 32 bytes long
byte remoteIp[4]; // holds recvieved packet's originating IP
unsigned int remotePort[1]; // holds received packet's originating port
String receivedString;
String udpString (32);

// ETHERNET CONFIGURATION
byte mac[] = {   0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = {   192, 168, 0, 193 };                      // LED Master IP address
byte gw[] = {   192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = { 192, 168, 0, 2 }; //75, 194, 243, 131  192, 168, 0, 2
int targetPort = 6000;


void setup() {
  // open the serial port:
  Serial.begin(9600);
  // Say hello:
 // Serial.print("String Library version: ");
 // Serial.println(inString.version());

  Ethernet.begin(mac,ip,gw);
  UdpString.begin(localPort);

}


void loop () {

  // if there's data available, read a packet
  if(UdpString.available()) {
    int packetSize = UdpString.readPacket(packet,remoteIp,remotePort);

   // Serial.print("Received packet of size ");
   // Serial.println(packetSize);

   // Serial.print("From IP ");
    for(int i=0; i<3; i++) {
     // Serial.print(remoteIp[i],DEC);
     // Serial.print(".");
    }
   // Serial.print(remoteIp[3],DEC);

   // Serial.print(" Port ");
   // Serial.println(remotePort[0]); 

  // Serial.println("Contents:");
  // Serial.println(packet);




    if (packet.contains("#") && packet.contains("end")) {      // Proceed if the start marker "#" is present within inString
    
    //  Serial.println("Good string!");

      String udpString(32);
      udpString.append(packet);                                // Transfer inString to udpString:

    //  Serial.println("string complete: ");
    //  Serial.println(packet);
    //  Serial.println("rain!");
    
      inString = "";                                           // Clear inString - we'll use udpString for parsing

      parseString();                                           // Parse udpString

     // printParse();                                            // Print the result of parseString()

      ledSend();

      udpString = "";                                          // Clear udpString so it's ready for the next time
      
    }
    else {
  //    Serial.println("please send # to start.");               // If no start marker "#", then clear inString and start over:
      inString = "";
    }

  }

  delay(10);
}



void parseString() {                                     // Break the string at ";" and place each section in an array called myStrings:

  char *p = packet; 
  char *i,*f;
  myStrings[0] =  strtok_r(p, "&", &i);                  // look at & and remember everything to the left of &, put in myStrings[0], point to where & is and call it &i)
  nextString[0] =  strtok_r(myStrings[0], "=", &f);      // look at myString[0] and remember everything to the left of =, put it in nextString[0], remember where you were at &f
  nextString[1] = strtok_r(NULL, "=", &f);               // when NULL it knows we want second iteration for &f, look to right of = instead of left, put it in nextString[1]
  // Serial.println(nextString[0]);
  // Serial.println(nextString[1]);

  for (int j = 1; j < 6; j++){                           // we just did [0] now we do the rest [1] - [5]
    myStrings[j] =  strtok_r(NULL, "&", &i);             // started looking left to get myStrings[0], but now we want second iteration for &i so we look to right side of & 
    nextString[j*2] =  strtok_r(myStrings[j], "=", &f);  // take myStrings[j], look to left of =, put it in nextString[j*2] (which is position [3] at first), point to where you were and call it &f
    nextString[(j*2) + 1] =  strtok_r(NULL, "=", &f);  // now we look to the right of = for second iteration of &f, put it in nextString[(j*2)+1] (which is position [4] at first), now we're pointing to end of string which is &f (but if we did another strtok_r it would error because string is empty)
    new_data[j-1] = nextString[(j*2)+1];
    char *fdsrt = "id";
    //Serial.println(new_data[j-1]);
    // Serial.println(nextString[j*2]);
    // Serial.println(nextString[(j*2) + 1]);

    if (strcmp(nextString[j*2], "id") == 0) {
      id = nextString[(j*2) + 1];
    }   

    else if (strcmp(nextString[j*2], "fishon") == 0) {
      fishon = nextString[(j*2) + 1];
    }   

    else if (strcmp(nextString[j*2], "dissox") == 0) {
      dissox = nextString[(j*2) + 1];
    }   

    else if (strcmp(nextString[j*2], "event") == 0) {
      event = nextString[(j*2) + 1];
    }

  } 
}


void ledSend() {
  String ledString = String(maxLength);
  strcpy (ledString,id);
  strcat (ledString,fishon);
  strcat (ledString,dissox);
  strcat (ledString,event);    
//  Serial.print("id fishon dissox event :: ");  
//  Serial.println(ledString);
  Serial.write(ledString);
  IDincoming = "";
  inString = "";
  udpString = "";
}


void printParse() {
  Serial.print ("ID = ");
  Serial.println (id);
  Serial.print ("dissox = ");
  Serial.println (dissox);
  Serial.print ("event = ");
  Serial.println (event);
  Serial.print ("fish on? = ");
  Serial.println (fishon); 
}

/* the end */
