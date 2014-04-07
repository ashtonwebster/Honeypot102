#!/bin/bash
#set vz id
vz=$1
outputfile=txtfiles/ping_$vz_output.txt
echo "starting ping script for container: $vz" >> $outputfile
date >> $outputfile

vzctl exec $vz 'ping google.com -t 5 -c 5' >> $outputfile
numreceived=$(grep received $outputfile | tail -n 1 |cut -d" " -f4) 
echo $numreceived
if [ $numreceived -eq 0 ] 
then
	echo fail, no packets received >> $outputfile
else
	echo success, all packets received >> $outputfile
fi	

echo "stopping ping script" >> $outputfile
date >> $outputfile

