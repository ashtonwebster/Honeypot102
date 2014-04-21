#!/bin/bash

#tails the log files, which means all modifications will be routed to the new file
#which is saved on the hpvm instead of the hp container

logfile=$1
vz=$2
if [ -z "$logfile" ]
then
	echo invalid args
	echo ./beginlogging logifle ctid
	exit
fi
if [ -z "vz" ]
then
        echo invalid args
	echo ./beginlooging logfile ctid
        exit
fi
filename=$(date | cut -d" " -f1-5 | perl -i -pe "s/ /_/g")
mkdir $logfile/attacks
tail -f /vz/private/$vz/var/log/syslog >>  $logfile/syslog_"$vz"_$filename.log &
tail -f /vz/private/$vz/var/log/auth.log >> $logfile/auth_"$vz"_$filename.log &
tcpdump >> $logfile/tcpdump_$filename.log &
