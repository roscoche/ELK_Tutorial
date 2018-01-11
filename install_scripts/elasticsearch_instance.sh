#!/usr/bin/env bash

mkdir /elk
cd /elk
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.1.1.zip
wget https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.zip
unzip elasticsearch-6.1.1.zip
unzip logstash-6.1.1.zip
mv elasticsearch-6.1.1 elasticsearch
mv logstash-6.1.1 logstash

rm *.zip
