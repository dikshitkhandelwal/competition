#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Update and install necessary packages
apt-get update
apt-get upgrade -y
apt-get install -y curl apt-transport-https wget lsb-release gnupg2

# Add the Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh-keyring.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

# Update package information
apt-get update

# Install Wazuh manager
apt-get install -y wazuh-manager

# Install Wazuh indexer
apt-get install -y wazuh-indexer

# Enable and start Wazuh indexer
systemctl daemon-reload
systemctl enable wazuh-indexer.service
systemctl start wazuh-indexer.service

# Install Kibana
apt-get install -y kibana

# Install Wazuh Kibana plugin
KIBANA_VERSION=$(kibana --version | cut -d "." -f 1,2)
/usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/4.x/ui/kibana/wazuh_kibana-$KIBANA_VERSION.zip

# Enable and start Kibana
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

# Install Filebeat
apt-get install -y filebeat

# Download Filebeat config for Wazuh
curl -so /etc/filebeat/filebeat.yml https://raw.githubusercontent.com/wazuh/wazuh/4.2/extensions/filebeat/7.x/filebeat.yml

# Download Wazuh module for Filebeat
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.1.tar.gz | tar -xvz -C /usr/share/filebeat/module

# Enable Filebeat system module
filebeat modules enable wazuh

# Setup Filebeat
filebeat setup --index-management -E setup.template.json.enabled=false

# Enable and start Filebeat
systemctl daemon-reload
systemctl enable filebeat.service
systemctl start filebeat.service

echo "Wazuh installation has completed."
echo "Access the Wazuh web interface through Kibana using the URL: http://<your_server_ip>:5601."
