#!/bin/bash
outputfile=txtfiles/pingoutput.txt
echo "starting ping script" >> outputfile
date >> outputfile

ping google.com -c 5 >> outputfile
numreceived=$(grep received txtfiles/outputfile | tail -n 1 |cut -d" " -f4) 
echo $numreceived
if [ $numreceived -eq 0 ] 
then
	echo fail, no packets received >> outputfile
else
	echo success, all packets received >> outputfile
fi	

echo "stopping ping script" >> outputfile
date >> outputfile

