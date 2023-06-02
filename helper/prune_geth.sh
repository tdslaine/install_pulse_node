#!/bin/bash

echo "WARNING: The execution-client will be stopped and pruning will begin. DO NOT interrupt the process."

read -p "Would you like to continue? (y/n): " CONTINUE
CONTINUE=${CONTINUE:-n}

if [ "$CONTINUE" != "y" ]; then
    echo "Exiting without making changes."
    exit 1
fi

# Prompt the user for their install path, default to /blockchain if nothing is entered
read -p "Enter the installation path [/blockchain]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain}
INSTALL_PATH="${INSTALL_PATH%/}"

echo "Using install path: $INSTALL_PATH"

# Stop the execution-client and prune Docker
docker stop -t 300 execution && docker container prune -f && docker rm execution -f

# Run the Docker command to prune the state
sudo docker run --rm --name geth_prune -it -v $INSTALL_PATH/execution/geth:/geth \
registry.gitlab.com/pulsechaincom/go-pulse:latest \
snapshot prune-state \
--datadir /geth

# Start the execution-client again after pruning
bash $INSTALL_PATH/start_execution.sh

echo "Pruning is done and execution-client is resumed. Please check the status of your execution-client."

