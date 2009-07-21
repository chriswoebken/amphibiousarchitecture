#!/bin/sh

# tick.sh
# fake some data
# jcl/nyu/2009-07-20

# Subversion $Id$

site=99
./udpsend 127.0.0.1 6000 "action=f1&site=$site&sensor=1&event=sms"

# fake day-of-month as nfish, 100+minute as weight, 200+minute as depth
#
nfish="`date '+%d'`"
weight="1`date '+%M'`"
depth="2`date '+%M'`"
./udpsend 127.0.0.1 6000 "action=f2&site=$site&sensor=1&nfish=$nfish&weight=$weight&depth=$depth"

# fake 9000+seconds as dissox micrograms/liter
#
dissox="90`date '+%M'`"
./udpsend 127.0.0.1 6000 "action=f3&site=$site&sensor=1&dissox=$dissox"

foodtype=1
weight=10
./udpsend 127.0.0.1 6000 "action=f4&site=$site&sensor=1&foodtype=$foodtype&weight=$weight"

caller=2125551212
msg=eriver
reply="river all good"
./udpsend 127.0.0.1 6000 "action=f5&site=$site&sensor=1&caller=$caller&msg=$msg&reply=$reply"

# end
