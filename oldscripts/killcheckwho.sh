#!/bin/bash
mine=$(ps -ef | grep checkwhovz | awk {'print $2'})
kill $mine
