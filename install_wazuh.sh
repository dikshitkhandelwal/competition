#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update the system
apt-get update
apt-get upgrade -y

# Install necessary packages
apt-get install -y curl apt-transport-https wget software-properties-common lsb-release

# Install Wazuh Manager
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
apt-get update
apt-get install -y wazuh-manager

# Install Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list
apt-get update
apt-get install -y elasticsearch

# Enable and start Elasticsearch service
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Install Kibana
apt-get install -y kibana

# Enable and start Kibana service
systemctl enable kibana.service
systemctl start kibana.service

# Install Filebeat
apt-get install -y filebeat

# Enable and start Filebeat service
systemctl enable filebeat.service
systemctl start filebeat.service

# Download the Wazuh module for Filebeat
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.1.tar.gz | tar -xvz -C /usr/share/filebeat/module

# Configure Filebeat to output to Elasticsearch
echo "output.elasticsearch.hosts: ['localhost:9200']" >> /etc/filebeat/filebeat.yml

# Enable the Wazuh module
filebeat modules enable wazuh

# Load the Filebeat template
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

# Restart Filebeat
systemctl restart filebeat

# Install the Wazuh plugin for Kibana (Make sure to replace `KIBANA_VERSION` with your Kibana version)
KIBANA_VERSION=$(kibana --version)
/usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-X.Y.Z_${KIBANA_VERSION}.zip

# Restart Kibana
systemctl restart kibana

echo "Wazuh installation has completed."
echo "You can access the Wazuh web interface through Kibana at http://<your_server_ip>:5601/app/wazuh"
