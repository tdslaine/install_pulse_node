#!/bin/bash

clear

check_directory() {
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist."
        exit 1
    fi
}


check_file() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found."
        exit 1
    fi
}

# Prompt user for blockchain folder
echo "Enter the blockchain folder (use TAB for autocomplete):"
read -e -p "Blockchain folder [default: /blockchain]: " BLOCKCHAIN_FOLDER
BLOCKCHAIN_FOLDER=${BLOCKCHAIN_FOLDER:-/blockchain}

# Check if the blockchain directory exists
check_directory "$BLOCKCHAIN_FOLDER"

# Prompt user to enter the keystore file 
echo "Enter the name of the keystore file (use TAB for autocomplete):"
read -e -p "Keystore file: " -i "$BLOCKCHAIN_FOLDER/" KEYSTORE_FILE

# Check if the keystore file exists
check_file "$KEYSTORE_FILE"

# Extract the filename from the full path
KEYSTORE_FILENAME=$(basename "$KEYSTORE_FILE")

# Run Docker command with automatic container removal
sudo docker run -it --rm --net=host \
    --name=avalidatorexit2 \
    -v $BLOCKCHAIN_FOLDER:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest lighthouse \
    --network pulsechain account validator exit \
    --keystore /blockchain/$KEYSTORE_FILENAME \
    --beacon-node https://rpc-pulsechain.g4mm4.io/beacon-api/
