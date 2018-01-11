#!/usr/bin/env bash

#Beware to define always the .tar.gz version of the file, otherwise the script should be modified to work with other files.
LOGSTASH_SRC='https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.tar.gz'
LOGSTASH_LOCAL_SRC='hpccdemo@192.168.56.101:/elk/logstash.tar.gz'
LOGSTASH_FILE='/elk/logstash.tar.gz'

echo "Node 2: Logstash"
echo "Making default ELK default directories and setting permissions"

sudo mkdir /elk
sudo chown hpccdemo:hpccdemo /elk
sudo chmod 755 /elk
mkdir /elk/logstash
mkdir /elk/samples

echo "Downloading and extracting Logstash..."
sudo apt-get install sshpass
sshpass -p "hpccdemo" scp -r $LOGSTASH_LOCAL_SRC $LOGSTASH_FILE
#wget -v $LOGSTASH_SRC -O $LOGSTASH_FILE
tar -xzf $LOGSTASH_FILE -C /elk/logstash --strip-components 1

echo "Downloading configuration files..."
wget -v https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml -O /elk/logstash/config/logstash.yml

echo "Downloading logstash parsers and samples..."
wget -v https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf -O /elk/logstash/apache.conf
wget -v https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf -O /elk/logstash/default.conf
wget -v https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/samples/apache_access.log -O /elk/samples/apache_access.log

echo "Logstash successfully configured in node 2."

