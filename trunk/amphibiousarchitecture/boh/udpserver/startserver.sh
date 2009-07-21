#!/bin/sh

# startserver.sh
# how to run amphib arch udp server
# jcl/nyu/2009-07-17

# first number is port we listen on
# remainder are acceptable client ip addresses
# output redirection jazz is disconnecting the output and run in background
#
./udpserver 6000  216.165.95.70 217.155.120.114 > /dev/null 2>&1 &

# check log to see if it started correctly
#
sleep 1
tail -1 /var/log/user.log

# end
