#!/usr/bin/bash

# load vars
source /tmp/vars

# install dependencies
sudo yum install -y vim net-tools epel-release
sudo yum install -y http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
sudo yum install -y zabbix-agent

# set up zabbix-sender and zabbix-agent
sudo yum install -y zabbix-sender zabbix-get

sudo rm -rf  /etc/zabbix/zabbix_agentd.conf
echo "
# Common
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
DebugLevel=3

# checks related
Server=${server_ip}
ServerActive=${server_ip}
ListenPort=10050
ListenIP=0.0.0.0
StartAgents=3
" > /etc/zabbix/zabbix_agentd.conf

systemctl enable zabbix-agent
systemctl start zabbix-agent


