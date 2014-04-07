#sleeps until the lastlogin file is modified.  This occurs when an attacker gains access.
#1800 seconds later it reimages (30 minutes).  There is a 50% chance of message in the 
#next login.

./sleep_until_modified.sh /vz/private/101/var/log/lastlog
vz=101
echo there are users online, to be kicked in 4 hours
./beginlogging.sh /home/hp/scripts/logfiles

sleep 1800 #sleep 4 hours
#rotate and kill logging
./killlogging.sh 
./rotate.sh /home/hp/scripts/logfiles
boolean=`expr $RANDOM % 2`
#ismessages saves whether the honeypot currently has a message or not
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
#important to run this in the background so you don't forkbomb
./betterlogstart.sh &
