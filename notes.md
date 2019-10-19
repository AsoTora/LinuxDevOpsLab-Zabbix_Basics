# Task

## info

Make scripts as much dynamic as possible.  
For example:  

- zabbix config: user+password info.
- zabbix_agent config: server_ip.

## extras

/etc/zabbix/zabbix_agentd.conf -- agent server.

## java getaway

In frontend we cpecify the port of the application we monitor. (12345)

gateway -- server with java-gateway installed

## cpu stress-test

source:  <https://www.cyberciti.biz/faq/stress-test-linux-unix-server-with-stress-ng/>

1. sudo yum install stress-ng
2. stress-ng --cpu 4 --timeout 60s --metrics-brief

## logs

### levels

for zabbix:  
zabbix_server -R log_level_increase

for java:  
change log-level /etc/zabbix/zabbix_java_gateway_logback.xml
