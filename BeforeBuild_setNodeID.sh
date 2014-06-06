#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'NodeID not supplied.'
    echo 'Obtain NodeID from master Zabbix server admin.'
    echo 'Usage: BeforeBuild_setNodeID.sh <node number>'
    exit 1
fi

sed -i "s/\# NodeID=0/NodeID=$1/" zabbix_server.conf
