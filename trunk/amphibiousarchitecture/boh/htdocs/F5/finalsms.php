<?php

require_once("../dbconfig.php");

$db = mysql_connect($dbhost, $dbuser, $dbpass);
 if (!$db) {
		syslog(LOG_ERR, "can't connect to db $dbhost, $dbuser");
                die("We couldn't service your request");
        }
        if (!mysql_select_db($dbname)) {
		syslog(LOG_ERR, "can't select db $dbname");
                die("We couldn't service your request");
        }



$keyword = strtolower($_GET['keywrd']);
$phone = $_GET['phoneno'];
$sArgs = strtolower(@$_REQUEST["args"]);

if($sArgs)
    $subkeyword = $sArgs;
else
    $subkeyword = 'NULL';
    
$sql = "select * from f10 where keyword='$keyword' and subkeyword='$subkeyword' ";

$res = mysql_query($sql);

if(mysql_num_rows($res) > 0) {
    if($row = mysql_fetch_assoc($res)) {
        $m = $row['message'];
        $site = $row['site'];
        
        /*
        //Get nfish
        $sql2 = "SELECT nfish FROM f2 WHERE id = ( SELECT MAX( id ) FROM f2 where site='$site')  ";    	
    	$res2 = mysql_query($sql2);     	
     	if ($row2 = mysql_fetch_assoc($res2)){    	
    		$nfish = $row2["nfish"];    		
    	}
    	
    	//Get message according to nfish value
    	if($nfish < 5) {
    	    $m = ;
    	elseif($nfish>=5 && $nfish<= 15) {
    	    $m = ;
	    else {
	        $m = ;
        }
    	*/
    	
    	echo $m;
    	
    	//Add reply to f5 table
    	$sql3 = "insert into f5 SET srcaddr='127.0.0.1', stamp=UTC_TIMESTAMP(), site='$site', sensor='1', caller='".addslashes($phone)."', msg='".addslashes($keyword)."',  reply='".addslashes($m)."' ";
		//$res3 = mysql_query($sql3);

		//Send UDP packet to the Mini for LED dance
		if($site == 1)
    		$minip = gethostbyname("amphibiouseast.dyndns.org");
    	else 
    	    $minip = gethostbyname("amphibiousbronx.dyndns.org");
		exec("php /srv/d_amphibious/home/adminftp/udpserver/udpsend $minip 10069 'action=f1&event=sms'");
    }
    else {
        syslog(LOG_ERR, "No record found");
        die("We couldn't service your request");
    }
}
else {
    syslog(LOG_ERR, "No record found");
    die("We couldn't service your request");
}



?>
