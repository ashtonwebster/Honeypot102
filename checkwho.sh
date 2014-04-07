#!/bin/bash
outputfile="txtfiles/who.log"
if [ $1 ]
then
vz=$1
echo "-----------------------" >> $outputfile
date >> $outputfile
vzctl exec $vz  'w' >> $outputfile

else
echo please enter a container!
fi

