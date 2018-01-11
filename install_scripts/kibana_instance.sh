#!/usr/bin/env bash

echo "Making default ELK directory, downloading, extracting and renaming the folders"
mkdir /elk
cd /elk
wget https://artifacts.elastic.co/downloads/kibana/kibana-6.1.1-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip
tar -xvzf kibana-6.1.1-linux-x86_64.tar.gz
unzip logstash-6.1.1.zip
mv kibana-6.1.1-linux-x86_64 kibana
mv logstash-6.1.1 logstash

echo "Cleaning"
rm *.zip *.gz

echo "Downloading configuration files..."
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/kibana.yml /elk/kibana/config/
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml /elk/logstash/config/
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml /elk/logstash/config/

echo "Downloading service script..."
sudo wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/services/kibana /etc/init.d/
sudo wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/services/logstash /etc/init.d/
sudo initctl reload-configuration
sudo service logstash start
sudo service kibana start

logout




