/* EA_SENSOR_SONAR.pde
 * Arduino 0016 with Arduino 2009
 * sonar hack, send udp formatted message via rs485 to sensor master every 2 seconds
 * kcw/theliving/2009.07.20
 * cw/xclinic/2009.08.06
 * dar/theliving/2009.08.13
 * ztc/xclinic/2009.08.13
 *
 * LIBRARIES REQUIRED:
 * UDP String: http://bitbucket.org/bjoern/arduino_osc/src/tip/libraries/Ethernet/
 * WString: http://wiring.org.co/learning/reference/String.html
 *** must include the following within the String library file WString.h:
 String(const int length = 16);
 String(const char* bytes);
 String(const String &str);
 ~String() { free(_array); } // <--- add this line
 *** adding this line "destructs" the string after each use. without
 it, the loop will evetually stop.
 *** read the forum about it:
 http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1231346812
 */

#include <UdpString.h>
#include <WString.h>

int analogPin = 4;

int nfish;
long count;
int fishOnOff;
int fishOnOfftrack = 0;
String onoff ="off";
int resetCount = 0;
String sendFinal;

int left = 7;
int middle = 8;
int right = 9;

int switchPin = 6; // use to walkie talkie talk through tx over rs485

void setup() {
  Serial.begin(9600);
  pinMode(switchPin, OUTPUT); 


  /******************************** simulate button press ****/
  pinMode(left, OUTPUT);
  pinMode(middle, OUTPUT);
  pinMode(right, OUTPUT);
  digitalWrite(middle, HIGH);
  delay(1000);
  digitalWrite(middle, LOW);
  delay(1000);

  // **** does this work?
  digitalWrite(middle, HIGH);
  delay(1000);
  digitalWrite(middle, LOW);
  delay(1000);
  // ****

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
  nfish = analogRead(analogPin);
 // Serial.println (nfish);
 
  count++;
  if (nfish > 80){
    //itoa (nfish, strTriggerFish, 10);
    fishOnOff = 100;

  }
  else if (nfish <= 80){
    //itoa (nfish, strTriggerFish, 10);
    fishOnOff = 0;   
  }

  if (fishOnOfftrack != fishOnOff || fishOnOfftrack == 1){
    onoff = "on" ;
  }
  char strNfish[4];
  itoa (nfish, strNfish, 10);
  fishOnOfftrack = fishOnOff;
  
  
  

  if (count % 20000 == 0){

    strcpy(sendFinal, "action=f2&site=2&sensor=1&nfish="); 
    strcat(sendFinal, strNfish);
    strcat(sendFinal, "&onoff=");
    strcat(sendFinal, onoff);
    strcat(sendFinal, "&csum=");



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
    //Serial.println (sendFinal);
    Serial.print(hexchar(csum >> 4), BYTE);     // 3) first character of the checksum
    Serial.print(hexchar(csum & 0x0f), BYTE);   // 4) second character of the checksum
    Serial.write("!!!");                        // 5) frame end
    Serial.println();
    //   delay(2000);
    digitalWrite(6, LOW);

    sendFinal = "";
    count = 0;
    onoff = "off";
  }

}





