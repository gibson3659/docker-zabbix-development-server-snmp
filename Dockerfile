FROM centos
MAINTAINER Ryo Tagami <ultrafortress@gmail.com>

# Update base images.
RUN yum distribution-synchronization -y

# Install EPEL, MySQL, Zabbix release packages.
RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN yum install -y http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
RUN yum install -y http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

# Install packages.
RUN yum install -y java-1.7.0-openjdk mysql-community-client mysql-community-libs-compat mysql-community-server openssh-server passwd perl-JSON python-simplevisor
RUN yum install -y zabbix-agent zabbix-get zabbix-java-gateway zabbix-sender zabbix-server zabbix-web zabbix-web-japanese zabbix-web-mysql
RUN yum install -y net-snmp snmptt

# Place configuration files.
ADD httpd.conf /etc/httpd/conf/httpd.conf
ADD my.cnf /etc/my.cnf
ADD simplevisor.conf /etc/simplevisor.conf
ADD sshd_config /etc/ssh/sshd_config
ADD zabbix.conf.php /etc/zabbix/web/zabbix.conf.php
ADD zabbix.ini /etc/php.d/zabbix.ini
ADD zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
ADD zabbix_java_gateway.conf /etc/zabbix/zabbix_java_gateway.conf
ADD zabbix_server.conf /etc/zabbix/zabbix_server.conf
RUN chown root:zabbix /etc/zabbix/zabbix_server.conf
RUN chmod 600 /etc/ssh/sshd_config
RUN chmod 640 /etc/zabbix/zabbix_server.conf

# https://github.com/dotcloud/docker/issues/1240#issuecomment-21807183
RUN echo "NETWORKING=yes" > /etc/sysconfig/network
# http://gaijin-nippon.blogspot.com/2013/07/audit-on-lxc-host.html
RUN sed -i -e '/pam_loginuid\.so/ d' /etc/pam.d/sshd

# Remove root password so that people can SSH.
RUN passwd -d root
# Generate a host key before packing.
RUN service sshd start; service sshd stop

# Create user and database.
RUN service mysqld start; mysql -uroot -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix'; CREATE DATABASE zabbix"; service mysqld stop

# Initialize zabbix database.
RUN service mysqld start; (cd `ls -1d /usr/share/doc/zabbix-server-mysql-*/create | tail -n 1`; cat schema.sql images.sql data.sql) | mysql -uroot zabbix; service mysqld stop

EXPOSE 22 80 10051 162
VOLUME ["/var/lib/mysql", "/usr/lib/zabbix/alertscripts", "/usr/lib/zabbix/externalscripts", "/etc/zabbix/zabbix_agentd.d"]
CMD ["/usr/bin/simplevisor", "--conf", "/etc/simplevisor.conf", "start"]
