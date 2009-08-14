<?php

/* smstest.php
 * Textmarks and a place to host this script online (currently kevinwei.com/sms.php)
 * send the sms keyword "AATEST" to 41411, Textmarks calls this php, it checks boh db for current sensor readings, 
 * it returns a response to Textmarks, Textmarks sends sms to your phone.
 * NOTICE: sms reply content not cleared for public use. please don't share this keyword with your friends ;-)
 * kcw/theliving/2009-07-30
 * ak/xclinic/2009-08-05
 */
 
require_once("dbconfig.php");



/******************************************* Check BOH DB for current sensor reading ****/
$db = mysql_connect($dbhost, $dbuser, $dbpass);
	if (!$db) {
		die("can't connect to db $dbhost, $dbuser");
	}
	if (!mysql_select_db($dbname)) {
		die("can't select db $dbname");
	}

	$sql1 = "SELECT dissox FROM f3 WHERE id = (SELECT MAX( id ) FROM f3 ) ";
	$res1= mysql_query($sql1);
	
		if ($row = mysql_fetch_assoc($res1))
		{
			$disox = $row["dissox"];
		}
	
	$sql2 = "SELECT nfish FROM f2 WHERE id = ( SELECT MAX( id ) FROM f2 )  ";
	
	$res2 = mysql_query($sql2); 
	
 	if ($row = mysql_fetch_assoc($res2)){
	
		$numfish = $row["nfish"];
		
	}
	
	$sql3 = " SELECT dunno FROM f6 WHERE id = ( SELECT max( id ) FROM f6 ) ";
	$res3= mysql_query($sql3);
	
		if ($row = mysql_fetch_assoc($res3))
		{
			$volume = $row["dunno"];
		}	
/******************************************************************************* end ****/



/**************************************** Talk to TextMarks API and set up menu list ****/
$sArgs = @$_REQUEST["args"];
	
if ($sArgs == NULL) {
    echo "Amphibious Architecture.\n";
    echo "dissox: " . $disox . "\n";
    echo " nfish: " . $numfish . "\n";
    echo " volume: " . $volume . "\n";
    echo "Rply M for Menu.";
    exit;
}

$ReplyCode 	= strtoupper($sArgs);
    
if ($sArgs != NULL) {
	switch($ReplyCode) {
    	case 'M': 
    	        $m = "Reply C to compare East River and Bronx River, L to listen to the river for 24 hrs, STOP to end updates.";
      		echo "Reply C to compare East River and Bronx River, L to listen to the river for 24 hrs, STOP to end updates.\n";
    		echo "-\n";
    		echo "For more info, go to www.ampharch.com";
    		break;
      	case 'C':
      		$m = "Right now, the Bronx River is louder than the East River. There are more fish in the East River. The D.O. level is higher in the Bronx River.";
   		echo "Right now, the Bronx River is louder than the East River. There are more fish in the East River. The D.O. level is higher in the Bronx River.\n"; 
   		echo "-\n";
   		echo "Reply M for Menu.";
   		break;
   	case 'L':
   		$m = "This feature is currently under development!";
   		echo "This feature is currently under development!\n";
   		echo "-\n";
   		echo "Rply M for Menu.";
		break;
	default:
		$m = "We couldnt service your request";
		echo "We couldnt service your request";
		break;
    	}
}
/******************************************************************************* end ****/



/********************************************** Tell BOH DB that someone sent an SMS ****/

$sql22 = "insert into f5 SET srcaddr='127.0.0.1',
	stamp=UTC_TIMESTAMP(), site='2', sensor='1', caller='$caller', msg='$sArgs', reply='$m' ";

$res22= mysql_query($sql22);

/******************************************************************************* end ****/



/********************************************* Tell BOH to send a packet to Mac Mini ****/

exec("./../../udpserver/udpsend 70.107.241.104 10069 'action=f1&event=sms'");

/******************************************************************************* end ****/


/* the end */
?>