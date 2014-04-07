#!/bin/bash

#tails the log files, which means all modifications will be routed to the new file
#which is saved on the hpvm instead of the hp container

logfile=$1
message=$(cat ismessage)
echo message: $message
if [ -z "$logfile" ]
then
	echo invalid args
	echo ./beginlogging logfile message
	exit
fi
if [ -z "$message" ]
then
        echo invalid args
        exit
fi
filename=$(date | cut -d" " -f1-5 | perl -i -pe "s/ /_/g")
tail -f /vz/private/101/var/log/syslog >>  $logfile/syslog_"$message"_101_$filename.log &
tail -f /vz/private/102/var/log/syslog >> $logfile/syslog_"$message"_102_$filename.log &
touch $logfile/
tail -f /vz/private/101/var/log/auth.log >> $logfile/auth_"$message"_101_$filename.log &
tail -f /vz/private/102/var/log/auth.log >> $logfile/auth_"$message"_102_$filename.log &
tcpdump >> $logfile/tcpdump_"$message"_$filename.log &
