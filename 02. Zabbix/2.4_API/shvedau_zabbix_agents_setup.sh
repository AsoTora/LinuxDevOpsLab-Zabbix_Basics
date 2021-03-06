#!/usr/bin/bash

# vars
source /vagrant/variables.conf

# install dependencies
sudo yum install -y vim net-tools epel-release
sudo yum install -y http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm
sudo yum install -y zabbix-agent

# agent configuration
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


# Tomcat
install_tomcat (){
    sudo yum install -y java-1.8.0-openjdk.x86_64
    sudo yum install -y java-1.8.0-openjdk-devel

    if [ ! -d "/opt/tomcat" ]; then
        sudo mkdir -p /opt/tomcat
    cd /tmp

    sudo groupadd tomcat
    sudo useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

    wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.47/bin/apache-tomcat-8.5.47.tar.gz
    tar -zxvf apache-tomcat-8.5.47.tar.gz
    cp -r /tmp/apache-tomcat-8.5.47/* /opt/tomcat/

    sudo chown -R tomcat:tomcat /opt/tomcat*
    sudo chmod -R g+x /opt/tomcat/conf/*
    fi

    if [ ! -f "/etc/systemd/system/tomcat.service" ]; then
        sudo echo '
        [Unit]
        Description=Apache Tomcat Web Application Container
        After=syslog.target network.target

        [Service]
        Type=forking

        Environment=JAVA_HOME=/usr/lib/jvm/jre
        Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
        Environment=CATALINA_HOME=/opt/tomcat
        Environment=CATALINA_BASE=/opt/tomcat
        Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC
        Environment="JAVA_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port='${jmx_port}' -Dcom.sun.management.jmxremote.rmi.port='${rmi_port}' -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname='${agent_ip}'"

        ExecStart=/opt/tomcat/bin/startup.sh
        ExecStop=/bin/kill -15 $MAINPID

        User=tomcat
        Group=tomcat

        [Install]
        WantedBy=multi-user.target
        ' > /etc/systemd/system/tomcat.service
        sudo systemctl daemon-reload
    fi

    sudo systemctl start tomcat
}
install_tomcat

# remote module
wget http://repo2.maven.org/maven2/org/apache/tomcat/tomcat-catalina-jmx-remote/8.5.47/tomcat-catalina-jmx-remote-8.5.47.jar
sudo cp tomcat-catalina-jmx-remote-8.5.47.jar /opt/tomcat/lib/

# set-up python env
sudo yum install -y python-pip
sudo pip install --upgrade pip
pip install py-zabbix
pip install pyzabbix

python2 /vagrant/host_register.py
