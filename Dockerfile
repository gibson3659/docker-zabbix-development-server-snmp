FROM centos:centos6
MAINTAINER  Jason Gibson <jason.gibson@guavus.com>

# Update base images.
RUN yum distribution-synchronization -y

# Install EPEL, MySQL, Zabbix release packages.
RUN yum install -y http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm \
                   http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm \
                   http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm 

# Install packages.
RUN yum install -y java-1.7.0-openjdk mysql-community-client mysql-community-libs-compat mysql-community-server passwd perl-JSON python-simplevisor net-snmp-perl snmptt
RUN yum --disablerepo="epel" install -y zabbix zabbix-agent zabbix-server-mysql zabbix-web-mysql zabbix-java-gateway

#necessary since the 2.2.3 package does not include the create scripts.  files extracted from 2.2 rpms
ADD zabbix_sql.tgz /usr/share/doc/zabbix-server-mysql-2.2.3/

# Place configuration files.
ADD httpd.conf /etc/httpd/conf/httpd.conf
ADD my.cnf /etc/my.cnf
ADD simplevisor.conf /etc/simplevisor.conf
ADD snmptt.tgz /etc/snmp/
ADD zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
RUN chown apache:apache /etc/zabbix/web/zabbix.conf.php
ADD zabbix.ini /etc/php.d/zabbix.ini
ADD zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
ADD zabbix_java_gateway.conf /etc/zabbix/zabbix_java_gateway.conf
ADD zabbix_server.conf /etc/zabbix/zabbix_server.conf
ADD php.ini /etc/php.ini
ADD container_init /boot/container_init.sh
RUN chmod 755 /boot/container_init.sh
ADD initialize_zabbix_db /root/initialize_zabbix_db.sh
RUN chmod 755 /root/initialize_zabbix_db.sh

EXPOSE 80 10051 162/udp
VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD ["/boot/container_init.sh"]
ENTRYPOINT ["/boot/container_init.sh"]
