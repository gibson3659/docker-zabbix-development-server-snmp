#!/bin/bash
args=`getopt t:n:d $*`

if test $? != 0
     then
         echo "Usage: $0 -t <target directory> -n <NodeID> -d"
         echo '   <target directory>  The target directory where the db and other persistent data is stored outside the container'
         echo '   <NodeID>            Obtain NodeID from the master Zabbix server admin'
         echo '   -d                  Leaves a bash shell running on the container to attach for debugging or further customization'
         exit 1
fi

echo "Configuration:"
set -- $args
for i
do
  case "$i" in
        -t) shift;basedir="$1";echo "Target directory = $basedir";shift;;
        -n) shift;NodeID=$1;echo "NodeID = $NodeID";shift;;
        -d) shift;echo "A debug shell will be started";debug="-d";
  esac
done

read -p "Press [Enter] key to build and run..."

sed "s/\# NodeID=0/NodeID=$NodeID/" zabbix_server.conf.template > zabbix_server.conf

docker build -t zabbix2.2 .

docker run -i -t -p 8022:22 -p 8080:80 -p 10051:10051 -p 162:162/udp \
       -v $basedir/mysqldata:/var/lib/mysql/:rw \
       -v $basedir/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:rw \
       -v $basedir/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:rw \
       -v $basedir/zabbix/zabbix_agentd.d:/etc/zabbix/zabbix_agentd.d:rw \
       --name zabbix zabbix2.2 $debug
