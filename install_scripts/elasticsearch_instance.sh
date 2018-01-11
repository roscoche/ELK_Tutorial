#!/usr/bin/env bash

echo "Node 1: Elasticsearch and Logstash"
echo "Making default ELK directory, downloading, extracting and renaming the folders"
mkdir /elk
cd /elk
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.1.1.zip
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip
unzip elasticsearch-6.1.1.zip
unzip logstash-6.1.1.zip
mv elasticsearch-6.1.1 elasticsearch
mv logstash-6.1.1 logstash

echo "Cleaning"
rm *.zip

echo "Downloading configuration files..."
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/elasticsearch.yml /elk/elasticsearch/config/
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml /elk/logstash/config/

echo "Downloading logstash parsers..."
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf /elk/logstash/
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf /elk/logstash/

echo "Downloading service script..."
sudo wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/services/elasticsearch /etc/init.d/
echo "Configuring service..."
chmod 700 /etc/init.d/elasticsearch
update-rc.d elasticsearch defaults
update-rc.d elasticsearch enable
echo "Reloading configurations..."
sudo initctl reload-configuration
sudo service elasticsearch start
echo "Elasticsearch and Logstash successfully configured in node 1."
logout
