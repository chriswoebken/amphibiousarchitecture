<?php

# test2.php
# simple web/php tests
# jcl/nyu/2009-07-19

# Subversion $Id$

function dumptable($table) {
	printf("<h2>%s</h2>", $table);

	$sql = sprintf("select * from %s order by id desc limit 100", $table);

	$res = mysql_query($sql);
	if (!$res) {
		printf("problem with sql query");
		return;
	}

	printf("<table border=1>");
	$rownum = 0;
	while ($row = mysql_fetch_assoc($res)) {
		++$rownum;
		if ($rownum == 1) {
			printf("<tr>");
			foreach ($row as $key => $col) {
				printf("<th>%s\n", $key);
			}
		}
		printf("<tr>");
		foreach ($row as $key => $col) {
			printf("<td>%s\n", $col);
		}
	}
	printf("</table>");
}

function main($dbhost, $dbuser, $dbpass, $dbname) {
	printf("<h1>Table Dump</h1>");
	printf("(%s)\n", strftime("%Y%m%d-%H%M%S"));

	$db = mysql_connect($dbhost, $dbuser, $dbpass);
	if (!$db) {
		die("can't connect to db $dbhost, $dbuser");
	}
	if (!mysql_select_db($dbname)) {
		die("can't select db $dbname");
	}

	foreach (array("f1", "f2", "f3", "f4", "f5", "f6") as $table) {
		dumptable($table);
	}
	printf("<hr>\n");
}

require_once("dbconfig.php");
main($dbhost, $dbuser, $dbpass, $dbname);

?>
