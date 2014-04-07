#!/bin/bash
#
vz=$1
#if you do not specify args, tell how to use properly 
if [ -z $vz ]
then
	echo invalid arguments, correct usage is:
	echo ./checkwho {ctid}
	exit
fi
#if already running, don't run
isrunning=$(ps -ef | grep checkwhovz | wc -l) 
echo $isrunning
if [ $isrunning -gt 20 ]
then
	echo already running
	exit
fi
cd /home/hp/scripts
outputfile="txtfiles/who.log"
echo "-----------------------"  | tee $outputfile
date  | tee $outputfile
vzctl exec 101 'w'  | tee $outputfile
usersonline=$(vzctl exec 101 'who' | sort | uniq -f 1 | wc -l)
echo $usersonline
echo users online $usersonline  | tee $outputfile
echo user ip addresses  | tee $outputfile
ip=$(vzctl exec 101 'who' | awk '{ print $NF }' | sed 's/(//g' | sed 's/)//g' |  cut -d. -f1 | sed 's/-/./g')

if [ $usersonline != 0 ] 
then
echo "there are attackers on the system with ip $ip" | mail groupkrules@gmail.com
echo there are users online, to be kicked in 4 hours

sleep 1800 #sleep 4 hours
boolean=`expr $RANDOM % 2`
echo $boolean > home/hp/scripts/ismessage	
if [ $boolean == 1 ]
	then 
		echo reimaging WITH MESSAGE 
		if [ $vz -eq 102 ]; then
			/home/hp/scripts/reimage.sh /vz/dump/vzdump-102-base-backup.tgz 102
			echo "" > vz/private/101/etc/motd
			/home/hp/scripts/killlogging.sh
			/home/hp/scripts/rotate.sh /home/hp/scripts/logfiles 
			/home/hp/scripts/beginlogging.sh /home/hp/scripts/logfiles 
		elif [ $vz -eq 101 ]; then
			/home/hp/scripts/reimage.sh /vz/dump/vzdump-101-base-backup.tgz 101
			echo "" > vz/private/101/etc/motd
			/home/hp/scripts/rotate.sh /home/hp/scripts/logfiles 
			/home/hp/scripts/beginlogging.sh /home/hp/scripts/logfiles 
		else 
			echo not a valid ctid
		fi	
	else 
		echo reimaging WITHOUT MESSAGE
		if [ $vz -eq 102 ]; then 
                        /home/hp/scripts/reimage.sh /vz/dump/vzdump-102-base-backup.tgz 102
			echo "### WARNING: UNAUTHORIZED USER DETECTED.  ALL ACTIONS WILL BE LOGGED ###" > /vz/private/102/etc/motd
			/home/hp/scripts/rotate.sh /home/hp/scripts/logfiles 
			/home/hp/scripts/beginlogging.sh /home/hp/scripts/logfiles &
                elif [ $vz -eq 101 ]; then
                        /home/hp/scripts/reimage.sh /vz/dump/vzdump-101-base-backup.tgz 101
                	echo "### WARNING: UNAUTHORIZED USER DETECTED.  ALL ACTIONS WILL BE LOGGED ###" > /vz/private/101/etc/motd
			/home/hp/scripts/rotate.sh /home/hp/scripts/logfiles 
			/home/hp/scripts/beginlogging.sh /home/hp/scripts/logfiles &
		else
                        echo not a valid ctid
                fi
	fi
else 
sleep 3
fi
#recursive call
./checkwhovz.sh $vz & >> /home/hp/scripts/txtfiles/whooutput.txt
exit

