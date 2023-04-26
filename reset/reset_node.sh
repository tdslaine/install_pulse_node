#!/bin/bash

# Define the ASCII table as a multi-line string
TABLE="
╔══════════════════════════════════════════════════╗
║ WARNING! WARNING! WARNING! WARNING!              ║
╟──────────────────────────────────────────────────╢
║ This script will reset and remove all            ║
║ Node/Validator related files, including          ║
║ downloaded Docker images. By default, this script║
║ will delete everything in the /blockchain folder.║
╟──────────────────────────────────────────────────╢
║ The files deleted cannot be recovered. Are you   ║
║ sure you want to continue (y/n)?                 ║
╚══════════════════════════════════════════════════╝
"

# Print the ASCII table to the terminal
echo "$TABLE"

# Prompt the user for confirmation
read -p "Enter 'y' to continue or 'n' to cancel: " answer

# If the user confirms, proceed with the script
if [ "$answer" == "y" ]; then
  # Perform the reset and removal actions here
  echo "Resetting and removing files..."

sudo docker stop execution
sudo docker stop beacon
sudo docker stop validator

sudo docker rm execution
sudo docker rm beacon
sudo docker rm validator

sudo docker container prune -f

sudo docker rmi registry.gitlab.com/pulsechaincom/go-pulse:latest
sudo docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
sudo docker rmi registry.gitlab.com/pulsechaincom/erigon-pulse:latest
sudo docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse:latest

sudo userdel validator
sudo userdel geth
sudo userdel lighthouse

sudo rm -R /blockchain

else
  echo "Aborting reset and removal..."
  exit 1
fi
