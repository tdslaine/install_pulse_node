#!/bin/bash

# Define the ASCII table as a multi-line string
TABLE="
+-------------------------------------------------------------+
| This script will reset and remove everything Node/Validator |
| related! It defaults to /blockchain folder, and deletes     |
| everything that has been put in there, including the        |
| downloaded Docker images.                                   |
+-------------------------------------------------------------+
| WARNING: The files deleted are gone and cannot be recovered!|
+-------------------------------------------------------------+
|                    Action Summary                           |
+-------------------------------------------------------------+
| 1. Stop Docker containers                                   |
| 2. Remove containers                                        |
| 3. Remove stopped containers                                |
| 4. Remove Node and Validator users                          |
| 5. Remove Node and Validator data directories !             |
| 6. Remove configuration files                               |
+-------------------------------------------------------------+
| Are you sure you want to continue? (y/n)                    |
+-------------------------------------------------------------+"

clear
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
sudo docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl       
sudo docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/validator      
sudo docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain   
sudo docker rmi registry.gitlab.com/pulsechaincom/go-pulse 

sudo userdel validator
sudo userdel geth
sudo userdel lighthouse
sudo userdel prysm
sudo userdel erigon

sudo rm -R /blockchain

else
  echo "Aborting reset and removal..."
  exit 1
fi
