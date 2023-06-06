#!/bin/bash

# Prompt the user for the install location with a default value
read -e -p "Please enter the path to your install location (default is /blockchain): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain} # Use default path if user input is empty
INSTALL_PATH=${INSTALL_PATH%/} # Remove trailing slash if exists

# Define script paths
SCRIPTS=("$INSTALL_PATH/start_consensus.sh" "$INSTALL_PATH/start_execution.sh" "$INSTALL_PATH/start_validator.sh")

# Iterate over scripts and add them to crontab if they exist and are executable
for script in "${SCRIPTS[@]}"
do
    if [[ -x "$script" ]]
    then
        # Check if the script is already in the cron list
        if ! sudo crontab -l 2>/dev/null | grep -q "$script"; then
            # If it is not in the list, add script to root's crontab
            (sudo crontab -l 2>/dev/null; echo "@reboot $script > /dev/null 2>&1") | sudo crontab -
            echo "Added $script to root's cron jobs."
        else
            echo "Skipping $script - already in root's cron jobs."
        fi
    else
        echo "Skipping $script - does not exist or is not executable."
    fi
done

# Create a systemd service unit file
cat << EOF | sudo tee /etc/systemd/system/graceful_stop.service
[Unit]
Description=Gracefully stop docker containers on shutdown

[Service]
ExecStart=/bin/true
ExecStop=$INSTALL_PATH/helper/stop_docker.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd manager configuration
sudo systemctl daemon-reload

# Enable the new service to be started on bootup
sudo systemctl enable graceful_stop.service
sudo systemctl start graceful_stop.service

echo "Set up and enabled graceful_stop service. Activated cronjob to always restart docker clients after a reboot"
read -p "Press Enter to continue"

