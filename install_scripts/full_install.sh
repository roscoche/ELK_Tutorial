#!/usr/bin/env bash

#If your IP's are not configured correctly, modify here, otherwise, do not mind these lines.
ELASTICSEARCH_IP='192.168.56.101'
LOGSTASH_IP='192.168.56.102'
KIBANA_IP='192.168.56.103'

#Beware to define always the .tar.gz version of the file, otherwise the script should be modified to work with other files.
ELASTICSEARCH_SRC='https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.1.1.tar.gz'
LOGSTASH_SRC='https://artifacts.elastic.co/downloads/logstash/logstash-6.1.1.tar.gz'
KIBANA_SRC='https://artifacts.elastic.co/downloads/kibana/kibana-6.1.1-linux-x86_64.tar.gz'

#This is the path where the source codes will be stored
ELASTICSEARCH_FILE='/elk/elasticsearch.tar.gz'
LOGSTASH_FILE='/elk/logstash.tar.gz'
KIBANA_FILE='/elk/kibana.tar.gz'

#Setting up SSH connection between the nodes
echo "Setting up security keys, so communication between the nodes will be in a safer and easier way"

#:<<'COMMENT'
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo "Adding nodes to known hosts"
ssh-keyscan -H $ELASTICSEARCH_IP >> ~/.ssh/known_hosts
ssh-keyscan -H $LOGSTASH_IP >> ~/.ssh/known_hosts
ssh-keyscan -H $KIBANA_IP >> ~/.ssh/known_hosts

echo "Copying ElasticSearch ID to other nodes"
sshpass -p "hpccdemo" ssh-copy-id $LOGSTASH_IP
sshpass -p "hpccdemo" ssh-copy-id $KIBANA_IP

cat <<EOT >> ~/.ssh/config
Host ElasticSearchInstance
    Hostname $ELASTICSEARCH_IP
    StrictHostKeyChecking no
    Loglevel ERROR
Host LogstasgInstance
    Hostname $LOGSTASH_IP
    StrictHostKeyChecking no
    Loglevel ERROR
Host KibanaInstance
    Hostname $KIBANA_IP
    StrictHostKeyChecking no
    Loglevel ERROR
EOT

echo "Transmitting SSH key and configuration to other nodes"
scp -q ~/.ssh/id_rsa* 192.168.56.102:~/.ssh
scp -q ~/.ssh/id_rsa* $KIBANA_IP:~/.ssh
scp -q ~/.ssh/config $LOGSTASH_IP:~/.ssh
scp -q ~/.ssh/config $KIBANA_IP:~/.ssh

#========================= NODE 1 - ELASTICSEARCH AND LOGSTASH ================================
echo "                          Node 1: Elasticsearch and Logstash"
echo "Making default ELK default directories and setting permissions..."

sudo mkdir /elk
sudo chown hpccdemo:hpccdemo /elk
sudo chmod 755 /elk
mkdir /elk/elasticsearch
mkdir /elk/logstash
mkdir /elk/samples

echo "Downloading ELK..."
#wget -v $ELASTICSEARCH_SRC -O $ELASTICSEARCH_FILE
#wget -v $LOGSTASH_SRC -O $LOGSTASH_FILE
#wget -v $KIBANA_SRC -O $KIBANA_FILE

echo "Extracting Elasticsearch and Logstash..."
tar -xzf $ELASTICSEARCH_FILE -C /elk/elasticsearch --strip-components 1
tar -xzf $LOGSTASH_FILE -C /elk/logstash --strip-components 1

echo "Downloading configuration files..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/elasticsearch.yml -O /elk/elasticsearch/config/elasticsearch.yml
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml -O /elk/logstash/config/logstash.yml

echo "Downloading logstash parsers and samples..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf -O /elk/logstash/apache.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf -O /elk/logstash/default.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/samples/apache_access.log -O /elk/samples/apache_access.log

echo "Downloading service script..."
sudo wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/services/elasticsearch -O /etc/init.d/elasticsearch
echo "Configuring service..."
sudo chmod 755 /etc/init.d/elasticsearch
sudo update-rc.d elasticsearch defaults
sudo update-rc.d elasticsearch enable
echo "Reloading configurations..."
sudo initctl reload-configuration
sudo service elasticsearch start
echo "Elasticsearch and Logstash successfully configured in node 1."

#COMMENT
#========================= NODE 2 - LOGSTASH ================================

ssh hpccdemo@$LOGSTASH_IP <<EOF
echo "======================================================================"
echo "				Node 2: Logstash"
echo "Making default ELK default directories and setting permissions"

sudo mkdir /elk
sudo chown hpccdemo:hpccdemo /elk
sudo chmod 755 /elk
mkdir /elk/logstash
mkdir /elk/samples

echo "Adding nodes to known hosts"
ssh-keyscan -H $ELASTICSEARCH_IP >> ~/.ssh/known_hosts
ssh-keyscan -H $LOGSTASH_IP >> ~/.ssh/known_hosts

echo "Downloading and extracting Logstash..."
scp -r $ELASTICSEARCH_IP:$LOGSTASH_FILE $LOGSTASH_FILE
tar -xzf $LOGSTASH_FILE -C /elk/logstash --strip-components 1

echo "Downloading configuration files..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml -O /elk/logstash/config/logstash.yml

echo "Downloading logstash parsers and samples..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf -O /elk/logstash/apache.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf -O /elk/logstash/default.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/samples/apache_access.log -O /elk/samples/apache_access.log

echo "Logstash successfully configured in node 2."
EOF


#========================= NODE 3 - KIBANA AND LOGSTASH======================
ssh hpccdemo@$KIBANA_IP <<EOF
echo "======================================================================"
echo ""
echo "                          Node 3: Kibana and Logstash"
echo ""
echo "======================================================================"
echo "Making default ELK directory, downloading, extracting and renaming the folders"

sudo mkdir /elk
sudo chown hpccdemo:hpccdemo /elk
sudo chmod 755 /elk
mkdir /elk/logstash
mkdir /elk/samples
mkdir /elk/kibana

echo "Downloading and extracting Logstash..."
ssh-keyscan -H $ELASTICSEARCH_IP >> ~/.ssh/known_hosts
scp -r $ELASTICSEARCH_IP:$KIBANA_FILE $KIBANA_FILE
scp -r $ELASTICSEARCH_IP:$LOGSTASH_FILE $LOGSTASH_FILE
tar -xzf $KIBANA_FILE -C /elk/kibana --strip-components 1
tar -xzf $LOGSTASH_FILE -C /elk/logstash --strip-components 1

echo "Downloading configuration files..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/kibana.yml -O /elk/kibana/config/kibana.yml
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/config_files/logstash.yml -O /elk/logstash/config/logstash.yml

echo "Downloading logstash parsers and samples..."
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/apache.conf -O /elk/logstash/apache.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/examples/default.conf -O /elk/logstash/default.conf
wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/samples/apache_access.log -O /elk/samples/apache_access.log

echo "Downloading service script..."
sudo wget -q https://raw.githubusercontent.com/roscoche/ELK_tutorial/master/install_scripts/services/kibana -O /etc/init.d/kibana
echo "Configuring service..."
sudo chmod 755 /etc/init.d/kibana
sudo update-rc.d kibana defaults
sudo update-rc.d kibana enable
echo "Reloading configurations..."
sudo initctl reload-configuration
sudo service kibana start

echo "Kibana and Logstash successfully configured in node 3."
EOF
GREEN="\e[32m"
RESET="\e[0m"
echo -e "$GREEN ELK up and running! Enjoy :)$RESET"

