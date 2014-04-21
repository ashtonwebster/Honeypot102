#sleeps until the lastlogin file is modified.  This occurs when an attacker gains access.
#1800 seconds later it reimages (30 minutes).  There is a 50% chance of message in the 
#next login.

vz=$1

if [ -z "$vz" ]
then
	echo stopping: invalid arguments
	echo ./betterlogstart.sh {ctid}
	exit
fi

./sleep_until_modified.sh /vz/private/$vz/var/log/lastlog
echo there are users online, to be kicked in 30 minutes

mkdir /home/hp/scripts/logfiles/attacks
#./beginlogging.sh /home/hp/scripts/logfiles/attacks $vz

sleep 1800 #sleep 30 minutes
#rotate and kill logging
./killlogging.sh 
./rotate.sh /home/hp/scripts/logfiles
#ismessages saves whether the honeypot currently has a message or not
/home/hp/scripts/reimage.sh /vz/dump/vzdump-"$vz"-base-backup.tgz "$vz"
echo "" > /vz/private/$vz/etc/motd
./betterlogstart.sh $vz &
