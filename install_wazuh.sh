#!/bin/bash

# Exit if any command fails
set -e

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 
    exit 1
fi

# Update the system and install necessary packages
apt-get update
apt-get upgrade -y
apt-get install -y curl apt-transport-https wget lsb-release gnupg2

# Add the Wazuh repository
apt-key adv --fetch-keys https://packages.wazuh.com/key/GPG-KEY-WAZUH
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

# Add the Elastic repository
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-7.x.list

# Update package information
apt-get update

# Install Wazuh manager
apt-get install -y wazuh-manager

# Install Elasticsearch
apt-get install -y elasticsearch

# Configure Elasticsearch to automatically start during boot
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

# Install Kibana
apt-get install -y kibana

# Enable and start Kibana
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

# Install Filebeat
apt-get install -y filebeat

# Download the Wazuh module for Filebeat
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.1.tar.gz | tar -xvz -C /usr/share/filebeat/module

# Configure Filebeat
cat > /etc/filebeat/filebeat.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/wazuh-alerts/*.json
    - /var/log/wazuh-archives/*.json

filebeat.config.modules:
  path: \${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression

setup.kibana:

output.elasticsearch:
  hosts: ['localhost:9200']
  protocol: "http"
  username: "elastic"
  password: "changeme"

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
EOF

# Enable the Wazuh module
filebeat modules enable wazuh

# Load the Filebeat template
filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["localhost:9200"]'

# Enable and start Filebeat
systemctl daemon-reload
systemctl enable filebeat.service
systemctl start filebeat.service

# Install Wazuh Kibana plugin
/usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-4.2.5_7.10.2-1.zip

# Restart Kibana
systemctl restart kibana

echo "Wazuh installation has completed."
echo "Access the Wazuh web interface through Kibana using the URL: http://<your_server_ip>:5601."
