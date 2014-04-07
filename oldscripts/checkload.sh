#!/bin/bash
value=$(uptime | cut -d" " -f13| cut -d"." -f1)
echo $value
if [ $value -gt 10 ]; then
	echo problem
else 
	echo fine
fi
