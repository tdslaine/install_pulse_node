#!/bin/bash

# Prompt the user to select the deposit-JSON file using a file dialog
json_file=$(zenity --file-selection --title="Select the deposit-JSON file")

# Check if the user selected a file
if [ -z "$json_file" ]; then
    echo "No file selected"
    exit 1
fi

# Check if the file exists
if [ ! -f "$json_file" ]; then
    echo "File not found"
    exit 1
fi

# Read JSON data from the selected file
json_data=$(cat "$json_file")

# Get the length of the JSON array
array_length=$(echo "$json_data" | jq 'length')

# Loop through the array and extract the fields from each object
for ((i=0; i<$array_length; i++)); do
    public_key=$(echo "$json_data" | jq -r --argjson index $i '.[$index].pubkey')
    withdrawal_credential=$(echo "$json_data" | jq -r --argjson index $i '.[$index].withdrawal_credentials')
    echo ""
    echo "Public Key: $public_key"
    echo "Withdrawal Credential: $withdrawal_credential"
    echo "------------------------------------"
    echo ""
done

#read -e -p "Please enter the withdrawal-Credentials starting with 00 you want to generate a bls-to-execution key: " bls_key
read -e -p "Please enter your installation folder: " install_path 

# Set the default installation path if the user didn't enter a value
if [ -z "$install_path" ]; then
    install_path="/blockchain"
fi

echo "getting staking cli and setting up venv..."


sudo mkdir -p ${install_path}/bls_converter
sudo chmod -R 777 ${install_path}/bls_converter
cd ${install_path}/bls_converter

git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git  > /dev/null 2>&1
cd staking-deposit-cli
pip3 install virtualenv > /dev/null 2>&1
virtualenv venv > /dev/null 2>&1
source venv/bin/activate > /dev/null 2>&1
python3 setup.py install > /dev/null 2>&1
pip3 install -r requirements.txt > /dev/null 2>&1

./deposit.sh --language english generate-bls-to-execution-change \
--chain pulsechain-testnet-v4
