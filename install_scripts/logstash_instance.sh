#!/usr/bin/env bash
echo "Node 1: Logstash"
echo "Making default ELK directory, downloading, extracting and renaming the folders"
mkdir /elk
cd /elk
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip
unzip logstash-6.1.1.zip
mv logstash-6.1.1 logstash

echo "Cleaning"
rm *.zip

echo "Downloading configuration files..."
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml /elk/logstash/config/

echo "Downloading logstash parsers..."
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf /elk/logstash/
wget https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf /elk/logstash/

echo "Done. bye!"
logout