#!/usr/local/php5/bin/php
<?php

# udpservershore
# udp server running on the shore computer (Mac Mini)
# based on boh's udpserver
# ak/nyu/2009-08-06

# Subversion $Id$

# takes udp packets
# runs required script (led dancing etc)
# config is in 'dbconfig.php'

# == handleevents
#
# takes a string in format "name=value&name=value..."
# one of the names must be "action=whattodo"
# depending on the action, the required script/commands
# are executed
# additional parameters may also be sent as required like
# "param1=xyz&param2=abc"
#
# error is logged to syslog
#
function handleevent($s) {
	$action = "";

	# add timestamp to array incase required (in utc)
	$items = array("stamp" => "utc_timestamp()");

	$box = split("&", $s);
	foreach ($box as $pair) {
		# add name/value pairs to the items array and set action
		$keyval = split("=", $pair);
		$key = $keyval[0];
		$val = $keyval[1];

		if ($key == "action") {
			$action = $val;
		} else {
			$items[$keyval[0]] = $keyval[1];	//not adding slashes, since
												//values not used in SQL 
		}
	}

	# check we know what action we're doing
	#
	if ($action == "") {
		echo("no 'action' in packet '$s'");
		return;
	}
	
	switch($action) {
		case 'f1':
			# execute the led dance script/send commands
			echo "\n \n \n";
			if($items['event'] == 'sms') {
				# Check for more sms's in past 4secs
				#$sql = "SELECT * FROM f5 WHERE stamp BETWEEN TIMESTAMPADD(SECOND, -4, UTC_TIMESTAMP()) AND UTC_TIMESTAMP()";
				#$res = mysql_query($sql);
				#if(mysql_num_rows($res) > 0) {		//There were sms's in past 4secs
					#exec("php ../boh/udpserver/udpsend 127.0.0.1 6000 'action=f1&event=sms-repeat'");
					#echo "repeat";
					#echo"\n\n\n\n";

			#	}
			#	else
				    exec("php ../boh/udpserver/udpsend 127.0.0.1 6000 'action=f1&event=sms'");
				echo "packet sent '$s'";
			}
			else
				echo "no event=sms found in '$s'";
			break;
		default:
			# unknown action 
            #echo "\nunknown action $s";
            #exec("./../boh/udpserver/udpsend 127.0.0.1 6000 'action=f1&event=sms'");

			echo("unknown action requested '$action'");

	}
	
}

function main($port, $okpeers, $dbhost, $dbuser, $dbpass, $dbname) {
	global $pid;

	$skt = @stream_socket_server("udp://0.0.0.0:$port",
		$errno, $errstr, STREAM_SERVER_BIND);
	if (!$skt) {
		echo("$pid: failed to make socket on port $port: $errstr");
		echo("$pid: exiting");
		die("failed to make socket on port $port: $errstr\n");
	}

	# db connection is available incase its required for some case
	$db = @mysql_connect($dbhost, $dbuser, $dbpass);
	if (!$db) {
		$msg = sprintf("mysql_connect error: %s", mysql_error());
		echo("$pid: $msg");
		echo("$pid: exiting");
		die("$msg\n");
	}
	if (!@mysql_select_db($dbname)) {
		$msg = sprintf("mysql_select_db error: %s", mysql_error());
		echo("$pid: $msg");
		echo("$pid: exiting");
		die("$msg\n");
	}

	for (;;) {
		# get the next packet
		#
		$pkt = stream_socket_recvfrom($skt, 1000, 0, $peer);

		# find out who sent the packet
		#
		$addrport = split(":", $peer);
		$peeraddr = $addrport[0];
		$peerport = $addrport[1];

		# check sender is in list of good senders
		#
		if (!in_array($peeraddr, $okpeers)) {
			echo(sprintf("%d: ignoring %d byte packet from %s",
					$pid, strlen($pkt), $peeraddr));
			continue;
		}

		# fake the sender as a field in the packet
		#
		$pkt .= sprintf("&%s=%s", "srcaddr", $peeraddr);

		# run the required script according to action
		#
		handleevent($pkt);
	}
}

# general startup
#
$pid = getmypid();

# pick up database details
# from the "amphibiousarchitecture/boh/udpserver" directory
# assuming here that this script is in "amphibiousarchitecture/shorecomp"
#
require_once("../boh/udpserver/dbconfig.php");

# pick up port and allowed client ip addresses from command line
#	always allow localhost 127.0.0.1
#
$port = $argv[1];
$addrs = array("127.0.0.1");
for ($i = 2;  $i < $argc;  ++$i) {
	$addrs[] = $argv[$i];
}
echo("$pid: server starting on port $port with allowed clients "
		. implode(" ", $addrs));

main($port, $addrs,
	$dbhost, $dbuser, $dbpass, $dbname);

# end
?>
