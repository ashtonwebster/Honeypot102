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
mkdir $logfile/old/attacks
mv $logfile/attacks/* $logfile/old/attacks
mv $logfile/* $logfile/old

/home/hp/scripts/beginlogging.sh $logfile 101
/home/hp/scripts/beginlogging.sh $logfile 102
#grep for beginlogging, tail, kill processes
#use scp to copy to datavm
sleep 3
scp /home/hp/scripts/logfiles/old/auth* $datavm:~/unsorted/auth/
scp /home/hp/scripts/logfiles/old/syslog* $datavm:~/unsorted/syslogdir/
scp /home/hp/scripts/logfiles/old/tcp* $datavm:~/unsorted/tcpdump/
scp /home/hp/scripts/logfiles/old/attacks/auth*	$datavm:~/unsorted/auth/attacks
scp /home/hp/scripts/logfiles/old/attacks/syslog* $datavm:~/unsorted/syslogdir/attacks
scp /home/hp/scripts/logfiles/old/attacks/tcpdump* $datavm:~/unsorted/tcpdump/attacks
#delete old logs
rm /home/hp/scripts/logfiles/old/*
