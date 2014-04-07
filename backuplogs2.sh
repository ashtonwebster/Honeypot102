#!/bin/bash
filename=$(date | cut -d" " -f2-4 | sed "s/ /_/g" | sed "s/:/./g")
tar -cvf vz_"$filename"_101_logs.tar /vz/private/101/var/log/*
scp vz_"$filename"_101_logs.tar data@192.168.1.21:/home/data/backups/logbackup
rm vz_"$filename"_101_logs.tar

