#!/bin/bash
vz=$1
if [ -z "$vz" ]
#adds the blocked ips to the iptables blacklist
then
	echo usage ./addtoblacklist {vz}
	exit
fi
cd /home/hp/scripts
vzctl exec $vz "iptables --flush"
FILENAME="blacklist.txt"
while read LINE; 
do
	vzctl exec $vz "iptables -A INPUT -s $LINE -j DROP"
	vzctl exec $vz "iptables -L"
done < $FILENAME
