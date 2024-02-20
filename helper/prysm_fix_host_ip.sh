#!/bin/bash

echo "This script is only for clients using Prysm. Do not run this if you use Lighthouse."

# Prompt the user to press Enter to continue or any other key to exit
read -n1 -p "Press Enter to continue or any other key to exit... " key

# Check the input
if [ "$key" = '' ]; then
    echo -e "\nContinuing..."
else
    echo -e "\nExiting..."
    exit 0
fi

# Prompt for the /blockchain folder
read -e -p "Enter your blockchain install folder (default is /blockchain): " blockchain_folder
blockchain_folder=${blockchain_folder:-/blockchain}

# Specify the path to your start script
start_script_path="${blockchain_folder}/start_consensus.sh"

# Check if the script contains the line for Prysm
if ! grep -q "prysm" "$start_script_path"; then
    echo "Prysm line not found in the script. Exiting..."
    echo ""
fi

# Flag to indicate if the IP retrieval block was added
ip_block_added=false

# Check if the IP retrieval block already exists
if ! grep -q "# Retrieve the current IP address" "$start_script_path"; then
    # Backup the original start script
    cp "$start_script_path" "${start_script_path}.bak"

    # Prepare the IP retrieval block with an additional empty line at the end
    ip_retrieval_block="#!/bin/bash

# Retrieve the current IP address
IP=\$(curl -s ipinfo.io/ip)
if [ -z \"\$IP\" ]; then
    echo \"Failed to retrieve IP address. Exiting...\"
    exit 1
fi

"
    # Insert the IP retrieval block
    { echo "$ip_retrieval_block"; tail -n +2 "${start_script_path}.bak"; } > "$start_script_path"
    ip_block_added=true
fi


p2p_line_updated=false

# Find the line with --p2p-host-ip and replace it, or add it before the last line if it doesn't exist
if grep -q -- "--p2p-host-ip" "$start_script_path"; then
    # Replace the existing --p2p-host-ip line
    sed -i "/--p2p-host-ip/c\--p2p-host-ip \$IP \\\\" "$start_script_path"
    p2p_line_updated=true
else
    # Add the --p2p-host-ip line before the last line if it doesn't exist
    sed -i "/^$/d; \$i\\--p2p-host-ip \$IP \\\\" "$start_script_path"
    p2p_line_updated=true
fi

# Make sure the start_consensus.sh script is executable
sudo chmod +x "$start_script_path"

# Output what has been updated
if $ip_block_added; then
    echo "IP retrieval block was added to the script."
fi

if $p2p_line_updated; then
    if $ip_block_added; then
        echo "Additionally, the --p2p-host-ip line was updated."
    else
        echo "The --p2p-host-ip line was updated."
    fi
else
    echo "No changes were made to the --p2p-host-ip line."
fi

echo "Updated $start_script_path successfully, restarting beacon client now"
echo ""
sleep 1
sudo docker stop -t 180 beacon
echo ""
sudo docker container prune -f
echo ""
sudo ${blockchain_folder}/start_consensus.sh
echo ""
echo "Adding beacon startup as system service"
sudo ${blockchain_folder}/helper/create_beacon_service.sh
echo ""
read -n1 -p "Press Enter to exit... "
