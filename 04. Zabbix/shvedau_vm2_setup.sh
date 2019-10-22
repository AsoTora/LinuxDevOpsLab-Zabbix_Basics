#!/usr/bin/bash

# vars
source /vagrant/variables.conf

# install dependencies
sudo yum install -y vim net-tools epel-release

# install kibana
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

echo "
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
" > /etc/yum.repos.d/kibana.repo

sudo yum install -y kibana 

# run kibana
sudo systemctl daemon-reload
sudo systemctl enable kibana.service
sudo systemctl start kibana.service

# install elasticsearch
echo "
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
" > /etc/yum.repos.d/elasticsearch.repo

# run
sudo yum install -y elasticsearch 
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# configure elastic
sudo cp -f /vagrant/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch.service

# configure kibana
sudo cp -f /vagrant/kibana.yml /etc/kibana/kibana.yml 
sudo systemctl restart kibana.service