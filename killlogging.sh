cd /home/hp/scripts
mine=$(ps -ef | grep tail | awk {'print $2'})
kill $mine
mine=$(ps -ef | grep beginlogging | awk {'print $2'})
kill $mine
mine=$(ps -ef | grep tcpdump | awk {'print $2'})
kill $mine
mine=$(ps -ef | grep sleep_until_modified | awk {'print $2'})
kill $mine
mine=$(ps -ef | grep sleep | awk {'print $2'})
kill $mine
