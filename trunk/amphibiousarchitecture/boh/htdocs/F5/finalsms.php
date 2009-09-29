<?php

require_once("../dbconfig.php");

$db = mysql_connect($dbhost, $dbuser, $dbpass);
 if (!$db) {
		syslog(LOG_ERR, "can't connect to db $dbhost, $dbuser");
                die("We couldn't service your request. 101");
        }
        if (!mysql_select_db($dbname)) {
		syslog(LOG_ERR, "can't select db $dbname");
                die("We couldn't service your request. 102");
        }

//print_r($_GET);

$keyword = strtolower($_GET['keywrd']);
$phone = $_GET['phoneno'];
$sArgs = strtolower(@$_REQUEST["args"]);

if($sArgs)
    $subkeyword = "='$sArgs'";
else
    $subkeyword = " IS NULL";
    
$sql = "select * from f10 where keyword='$keyword' and subkeyword $subkeyword ";

$res = mysql_query($sql);

if(mysql_num_rows($res) > 0) {
    if($row = mysql_fetch_assoc($res)) {
        $m = $row['message'];
        $site = $row['site'];
        
        
        //Get nfish
        $sql2 = "SELECT id, seconds(stamp) as secs, nfish FROM f2 WHERE  site='$site' and stamp between (utc_timestamp() - interval 1 HOUR) and utc_timestamp()  ";
        //$sql2 = "SELECT id, second(stamp) as secs, nfish FROM f2 WHERE  site='2' and stamp between ('2009-09-23 02:16:38' - interval 1 HOUR) and '2009-09-23 02:16:38'";    	    	
    	$res2 = mysql_query($sql2);     	
    	if(@mysql_num_rows($res2) > 0) {
    	    $nfish = 1;
         	while ($row2 = mysql_fetch_assoc($res2)) {
         	    //echo "p $prevSec c $currSec ".$row2['secs']." \n";
        		$currSec = $row2['secs'];
        		if($prevSec+1 == $currSec) {
        		    //echo "p$prevSec c$curSec";
        		    $prevSec = $currSec;
        		    continue;
    		    }
    		    else {
    		        //echo "\ncc".$nfish++."cc\n";
    		        $prevSec = $currSec;
		        }        		    
        	}
        	//echo "f $nfish f";
    	}
    	else
    	    $nfish = 0;
    	
    	$ctime = time();
    	$hrs = date('G', $ctime);
    	if($hrs >= 5 && $hrs < 12) 
    	    $greeting = "Good morning";
    	elseif($hrs >= 12 && $hrs < 17)
    	    $greeting = "Good afternoon";
   	   else
    	    $greeting = "Good evening";
    	
    	/*
    	//Get message according to nfish value
    	if($nfish < 5) {
    	    $m = ;
    	elseif($nfish>=5 && $nfish<= 15) {
    	    $m = ;
	    else {
	        $m = ;
        }
    	*/
    	
    	switch($keyword) {
    	    case 'tstbronx' :
    	        $m = $greeting.". ".$m;
    	}
    	
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
        die("We couldn't service your request. 103");
    }
}
else {
    syslog(LOG_ERR, "No record found");
    die("We couldn't service your request. 104");
}



?>
