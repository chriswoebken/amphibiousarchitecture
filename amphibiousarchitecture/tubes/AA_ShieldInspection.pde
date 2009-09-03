/* ST_tubeInspectionTest
 * Arduino 16 on Arduino 2009 using Adafruit Prototype Board
 * check to see that prototype board works, check to see that hardwire of tode ID on PINC works
 * kcw/theliving/2009.07.23
 */

int ledTest0 = 13;                // LED connected to digital pin 13
int ledTest1 = 12;

void setup()                    // run once, when the sketch starts
{
  pinMode(ledTest0, OUTPUT);      // sets the digital pin as output
  pinMode(ledTest1, OUTPUT);

  Serial.begin(9600);

  DDRC = B00000;                  // set port C to all inputs (binary 00000000)
  PORTC = B11111;                 // set port c to all HIGH (binary 1111111)
  /*
  pinMode(14, INPUT);
  pinMode(15, INPUT);
  pinMode(16, INPUT);
  pinMode(17, INPUT);
  pinMode(18, INPUT);
  //pinMode(19, INPUT);
  
  digitalWrite(14, HIGH);
  digitalWrite(15, HIGH);
  digitalWrite(16, HIGH);
  digitalWrite(17, HIGH);
  digitalWrite(18, HIGH);
  //digitalWrite(19, HIGH);
  */
}


void loop() { 

  int nodeID = PINC;            // PINC is the input register variable, it will read all pins on port C at the same time

  Serial.print("Tube ID (BIN): ");
  Serial.print(nodeID, BIN);
  Serial.println();
  Serial.print("Tube ID (DEC): ");
  Serial.print(nodeID);
  Serial.println();
  Serial.println();

  digitalWrite(ledTest0, HIGH);   
  digitalWrite(ledTest1, LOW);   
  delay(1000);                  
  
  digitalWrite(ledTest0, LOW);  
  digitalWrite(ledTest1, HIGH);     
  delay(1000);                  

}

// digital read pin 14 on analog pin 0
// digital read pin 15 on analog pin 1
// digital read pin 16 on analog pin 2
// digital read pin 17 on analog pin 3
// digital read pin 18 on analog pin 4
