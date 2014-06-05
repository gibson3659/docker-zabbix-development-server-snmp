#!/bin/bash

docker run -i -t -p 8080:80 -p 10051:10051 -p 162:162 -v /data1/mysqldata:/var/lib/mysql/:rw --name zabbix zabbix2.2 bash
