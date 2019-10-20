#!/usr/bin/bash

# vars
zabbix_db_pass="password"
DBName="zabbix"
DBUser="zabbix"
host="localhost"
zone="Europe/Minsk"
server_ip="192.168.56.11"
agent_ip="192.168.56.33"

# install dependencies
sudo yum install -y vim net-tools epel-release

# MariaDB
yum install -y mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl enable mariadb
systemctl start mariadb

mysql -uroot -e "create database zabbix character set utf8 collate utf8_bin"
mysql -uroot -e "grant all privileges on zabbix.* to '${DBUser}'@'${host}' identified by '${zabbix_db_pass}'"

# Zabbix Server
sudo yum install -y http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
sleep 5
sudo yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent

zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -u"${DBUser}" -p"${zabbix_db_pass}" zabbix

# Database configuration
sudo cp -f /vagrant/zabbix_server.conf /etc/zabbix/zabbix_server.conf
echo "
DBHost=${host}
DBName=${DBName}
DBUser=${DBUser}
DBPassword=${zabbix_db_pass}
" >> /etc/zabbix/zabbix_server.conf

sed -i "s-# php_value date.timezone Europe/Riga-php_value date.timezone ${zone}-" /etc/httpd/conf.d/zabbix.conf

# redirect
sudo echo "
<VirtualHost *:80>
        ServerName ${server_ip}
        DocumentRoot /usr/share/zabbix
</VirtualHost>
" > /etc/httpd/conf.d/vhosts.conf

systemctl enable httpd
systemctl enable zabbix-server
systemctl start zabbix-server
systemctl restart httpd

# local agent
sudo rm -rf /etc/zabbix/zabbix_agentd.conf
echo "
# Common
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
DebugLevel=3

# checks related
Server=127.0.0.1
ListenPort=10050
ListenIP=0.0.0.0
StartAgents=3
" > /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl start zabbix-agent


# set up java getaway
wget https://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-java-gateway-4.2.1-1.el7.x86_64.rpm
sudo yum install -y zabbix-java-gateway-4.2.1-1.el7.x86_64.rpm

systemctl enable zabbix-java-gateway
systemctl start zabbix-java-gateway

echo "
# Java Gateway settings
JavaGateway=${server_ip}
JavaGatewayPort=10052
StartJavaPollers=5
" >> /etc/zabbix/zabbix_server.conf

