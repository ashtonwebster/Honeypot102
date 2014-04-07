#!/bin/bash

#kills the logging and pushes the changes to the data vm, deleting the local copies

#stop logging
logfile=$1
datavm=data@192.168.1.21
cd /home/hp/scripts
if [ -z "$logfile" ] 
then
	echo correct usage
	echo ./rotatelogs logdirectory 
	exit
fi
./killlogging.sh
sleep 3
mkdir $logfile/old
mv $logfile/* $logfile/old
/home/hp/scripts/beginlogging.sh $logfile
#grep for beginlogging, tail, kill processes
#use scp to copy to datavm
sleep 3
scp /home/hp/scripts/logfiles/old/auth* $datavm:~/unsorted/auth/
scp /home/hp/scripts/logfiles/old/syslog* $datavm:~/unsorted/syslogdir/
scp /home/hp/scripts/logfiles/old/tcp* $datavm:~/unsorted/tcpdump/
#delete old logs
rm /home/hp/scripts/logfiles/old/*
