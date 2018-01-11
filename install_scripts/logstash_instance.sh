#!/usr/bin/env bash

mkdir /elk
cd /elk

wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip
unzip logstash-6.1.1.zip
mv logstash-6.1.1 logstash

rm *.zip
cd config
rm logstash.yml

wget 
echo 