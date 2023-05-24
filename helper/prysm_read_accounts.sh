#!/bin/bash

start_dir=$(pwd)
script_dir=$(dirname "$0")

source "$script_dir/functions.sh"
check_and_set_network_variables

# Prompt the user to enter the installation path
read -e -p "Enter the installation path (default: /blockchain): " INSTALL_PATH

# Set the default installation path if the user didn't enter a value
if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH="/blockchain"
fi

# Run the Docker command with the specified installation path
docker run --rm -it \
--name="read_keys" \
-v "${INSTALL_PATH}/wallet:/wallet" \
registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest \
accounts list \
--${PRYSM_NETWORK_FLAG} \
--wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt

read -p "Press Enter to continue..."
