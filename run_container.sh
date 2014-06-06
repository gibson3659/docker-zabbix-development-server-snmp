#!/bin/bash
basedir=/data1
["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
echo docker run -i -t -p 8022:22 -p 8080:80 -p 10051:10051 -p 162/udp:162/udp \
       -v $basedir/mysqldata:/var/lib/mysql/:rw \
       -v $basedir/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:rw \
       -v $basedir/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:rw \
       -v $basedir/zabbix/zabbix_agentd.d:/etc/zabbix/zabbix_agentd.d:rw \
       --name zabbix zabbix2.2
