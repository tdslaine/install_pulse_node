#!/bin/bash

# Prompt the user for the installation path with a default value
read -p "Enter the installation path [/blockchain]: " install_path
install_path=${install_path:-/blockchain}

# Define the path to the service file
service_file="/etc/systemd/system/beacon.service"

# Use sudo to create or overwrite the service file
sudo bash -c "cat > $service_file" <<EOF
[Unit]
Description=Consensus Client Startup Script
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=$install_path/start_consensus.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload the systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable beacon.service

# Start the service
sudo systemctl start beacon.service

echo "beacon.service has been created, enabled, and started."
