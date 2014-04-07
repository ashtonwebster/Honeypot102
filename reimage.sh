#!/bin/bash
#Bobby Crumbaugh
#reimaging the machine
backup=$1
vz=$2
outputfile="/home/hp/scripts/txtfiles/backupresults.txt"
echo "$outputfile"
cd /home/hp/scripts
if [ -z $backup ]
then
	echo stopping: invalid arguments:
	echo ./reimage {backup_file} {ctid}
	exit
fi

if [ -z "$vz" ]
then
	echo stopping: invalid arguments
	echo ./reimage {backup_file} {ctid}
	exit
fi

echo "----------------------------------"  >> $outputfile
echo "starting backup" | tee "$outputfile" 
date | tee "$outputfile" 
status=$(sudo vzctl status $vz | cut -d" " -f3-5);
if [ "$status" == "deleted unmounted down" ] 
then
	echo "container down, no backup created" | tee "$outputfile" 
else
	sudo vzctl status $vz | tee "$outputfile" 
	sudo vzctl stop $vz | tee "$outputfile" 
	sudo vzdump --maxfiles 2 --compress --stop $vz | tee "$outputfile" 

	backupname=$(grep /vz/dump/vzdump-openvz-$vz txtfiles/backupresults.txt | head -n 1 | cut -d" " -f4 | perl -i -pe "s/'//g")
	if [ "$backupname" ]
	then
		echo writing to $backupname | tee "$outputfile" 
	fi
	sudo vzctl destroy $vz | tee "$outputfile" 
fi
#restore from base case
sudo vzrestore $backup $vz | tee "$outputfile" 
sudo vzctl start $vz | tee "$outputfile" 
sleep 3
sudo brctl addif br0 veth101.0
sudo brctl addif br0 veth102.0
#/home/hp/scripts/addtoiptable.sh 101
#/home/hp/scripts/addtoiptable.sh 102

echo "stopping backup" | tee "$outputfile" 
date | tee "$outputfile"
