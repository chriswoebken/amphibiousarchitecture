/* EA_LIGHT_MASTER.pde
 * Arduino 0016 with Arduino 2009 and RS485
 * receive 'short format' UDP packet from ethernet sent from mini, send it over rs485 via serial.write().
 * kcw/theliving/2009.09.12
 * jcl/xclinic/2009.09.12
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

String packet(32); //packet can be max 32 bytes long
byte remoteIp[4]; // holds recvieved packet's originating IP
unsigned int remotePort[1]; // holds received packet's originating port

String udpString (32);


// ETHERNET CONFIGURATION
byte mac[] = {   0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };   // MAC address to use
byte ip[] = {   192, 168, 0, 193 };                      // LED Master IP address
byte gw[] = {   192, 168, 0, 1 };                        // Gateway IP address
int localPort = 8888;                                  // local port to listen on

// TARGET set this to IP/Port of computer that will receive UDP messages from Arduino
byte targetIp[] = {   192, 168, 0, 2 };
int targetPort = 6000;


void setup() {
  Serial.begin(9600);

  Ethernet.begin(mac,ip,gw);
  UdpString.begin(localPort);
}


void loop () {

  // if there's data available, read a packet
  if(UdpString.available()) {
    int packetSize = UdpString.readPacket(packet,remoteIp,remotePort);

    // if (packet.charAt(0) == '#' && packet.charAt(6) == '!' && packet.length() == 7) {
    if (packet.contains("#") && packet.contains("!")) {      // Proceed if the frames "#" and "!" are present

      String goodString(8);
      strcpy(goodString, packet);                               // Transfer packet to goodString:

      Serial.write(goodString);
      
      goodString = "";                                          // Clear goodString and packet so it's ready for the next time
      packet = "";

    }
    else {
      // If no frame "#" "!", then skip tiny delay and start over:
      return;
    }
  }

  delay(10);
}


/* the end */
