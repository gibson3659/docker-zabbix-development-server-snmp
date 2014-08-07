#!/bin/sh

nohup "`dirname $0`"/mikoomi-hadoop-jobtracker-plugin-helper.sh x $* 1>/dev/null 2>/dev/null & 
echo "Ok"
exit
