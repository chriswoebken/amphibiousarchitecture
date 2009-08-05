/* AA_InOutControl
 * Processing 1.0.5, Mac Mini, D-Link router/switch, set of ethernet'd sensors
 * InOutControl has three goals: 1) receive senor inputs 2) process the inputs for light behavior 3) output behavior commands to the 16 tubes
 * ** UDP ** receive udp packets from sensors, parse the message, make message content available for light behavior, forward udp to boh
 * ** LED ** process the message for light behavior, send the behavior commands to the tubes
 * kcw/theliving/2009-07-20
 */



/****************************************************************************************** UDP ****/
import hypermedia.net.*;
import processing.serial.*;
UDP udp;

int site = 0;       // these variable get filled in once a udp packet gets received and parsed
int sensor = 0;     // if any of them remain at zero and get sent to boh, then:
int volume = 0;     // sensor itself is reading a zero value, which should never happen
int dissox = 0;     // or there is a problem receiving udp packets from the sensors' ethernet
int nfish = 0;
int weight = 0;
int depth = 0;
/****************************************************************************************** END ****/



void setup() {

  /***************************************************************************************** UDP ****/

  udp = new UDP( this, 6000 );                     // create a new datagram connection on port 6000
  udp.log( true );                                 // printout the connection activity
  udp.listen( true );                              // wait for incomming message

  /***************************************************************************************** END ****/

}



void draw() {
}



/****************************************************************************************** UDP ****/

/* ------------------------------------ for testing only -- */
void keyPressed() {
  // String message  = str( key );                                  // the message to send
  String ip       = "92.243.23.29"; //"localhost";                  // the remote IP address
  int port        = 34567;                                          // the destination port

  String message = "action=f2&site=2&sensor=130&nfish=1";
  udp.send( message, ip, port );                                    // send the message

  if(message != null) {
    println("key pressed: " + message);
  }
}
/* ------------------------------------------------- end -- */



/* ----------------------- do this when you get a packet -- */
void receive( byte[] data, String ip, int port ) {                  // extended handler
  // void receive( byte[] data ) {                                  // default handler

  // data = subset(data, 0, data.length-1);
  String message = new String( data );



  /////////////////// send UDP to BOH ////
  String bohIP = "92.243.23.29";
  int bohPort  = 6000;
  udp.send( message, bohIP, bohPort );
  /////////////////////////////// end ////



  /////////////////// see the packets ////
  println( "receive: \""+message+"\" from "+ip+" on port "+port );

  String[] list = split(message, "&");                             // split 'message' at each "&"
                                                                   // put result in 'list'
  for(int i = 0; i < list.length; i++) {                           // iterate through all of 'list'
    String[] pair = split(list[i], "=");                           // split 'list' at each "="

    if (pair[0].equals("site")) {                                  // if parsed packet (pair[0]) equals tag word that we expect
      site = int(pair[1]);                                         // then set a variable equal to the following value (pair[1])
    }
    else if (pair[0].equals("sensor")) {                           // same as above
      sensor = int(pair[1]);                                       // do it for every tag word we expect to get
    }
    else if (pair[0].equals("volume")) {
      volume = int(pair[1]); 
    }
    else if (pair[0].equals("dissox")) {
      dissox = int(pair[1]); 
    }
    else if (pair[0].equals("nfish")) {
      nfish = int(pair[1]);
    }
    else if (pair[0].equals("weight")) {
      weight = int(pair[1]);
    }
    else if (pair[0].equals("depth")) {
      depth = int(pair[1]);
    }
  }

  println("volume = " + volume);                                   // monitor how the packet values change
  println("dissox = " + dissox);
  println("nfish = " + nfish);
  println();
  /////////////////////////////// end ////
}
/* ------------------------------------------------- end -- */
/****************************************************************************************** END ****/

/* the end */


