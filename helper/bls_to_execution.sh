#!/bin/bash

start_dir=$(pwd)
script_dir=$(dirname "$0")
source "$script_dir/functions.sh"
check_and_set_network_variables

sudo apt install jq zenity -y

# Prompt the user to select the deposit-JSON file using a file dialog
json_file=$(zenity --file-selection --title="Select the deposit-JSON file you wish to exit and scan it for pubkey/bls-withdrawal creds: ")

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

echo "The following procedure will ask you the following:"
echo ""
echo " - Path to your Blockchain installation"
echo " - Mnemonic you used to create the validator"
echo " - Starting index for the keys you want to convert (usually 0)"
echo " - The Validator index as shown on the pls-beacon-explorer ${LAUNCHPAD_URL}"
echo " - BLS withdrawal-Credentials (starting with 00)"
echo " - The new execution withdrawal wallet"
echo ""
echo "Note: You can enter multiple values, separated with a comma"
echo "      You can get your BLS-Withdrawal Credential above or via ${LAUNCHPAD_URL}/en/withdrawals"
echo ""

read -e -p "Please enter your installation folder (default: /blockchain): " install_path 

# Set the default installation path if the user didn't enter a value
if [ -z "$install_path" ]; then
    install_path="/blockchain"
fi

echo "Getting staking-cli and setting up venv..."

# Prepare directories
sudo mkdir -p ${install_path}/bls_converter
sudo chmod -R 777 ${install_path}/bls_converter
cd ${install_path}/bls_converter

# Clone and set up staking-deposit-cli
git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git > /dev/null 2>&1
cd staking-deposit-cli

# Create a virtual environment and activate it
python3.8 -m venv venv
source venv/bin/activate

# Install dependencies in the virtual environment
echo "Installing dependencies..."
pip install --upgrade pip setuptools > /dev/null 2>&1
pip install -r requirements.txt > /dev/null 2>&1
pip install . > /dev/null 2>&1

# Run staking-deposit-cli command
echo "Running staking-deposit-cli to generate BLS to execution changes..."
./deposit.sh --language english generate-bls-to-execution-change \
--chain ${DEPOSIT_CLI_NETWORK}

# Deactivate the virtual environment
deactivate

# Move generated files and clean up
echo "Copying over the conversion files..."
sudo mv ${install_path}/bls_converter/staking-deposit-cli/bls_to_execution_changes/*.json ${install_path}/bls_converter/
cd ${install_path}/bls_converter/
sudo rm -R staking-deposit-cli
sudo chmod -R 777 *.json

# Ask to submit changes
read -e -p "Do you wish to submit the bls-to-execution conversion to your beacon now? (y/n):" submit

if [[ $submit == "y" ]]; then
    echo "Please choose your beacon client"
    echo ""
    echo "1. Lighthouse"
    echo ""
    echo "2. Prysm"
    echo ""
    read -e -p "Choose 1 or 2: " client_choice

    if [[ $client_choice == "1" ]]; then
        sudo docker run --rm -it \
            -v ${install_path}/bls_converter:/bls_dir \
            --name submit_bls_change \
            --network host \
            registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest \
            validator withdraw \
            -beacon-node-host=localhost:5052 \
            --path=/bls_dir \
            --confirm

    elif [[ $client_choice == "2" ]]; then
        sudo docker run --rm -it \
            -v ${install_path}/bls_converter:/bls_dir \
            --name submit_bls_change \
            --network host \
            registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest \
            validator withdraw \
            -beacon-node-host=localhost:3500 \
            --path=/bls_dir \
            --confirm
    fi
else 
    echo "Don't forget to submit your changes to the network via your beacon..."
    read -p "Press enter to continue..."
    exit 0
fi

sudo docker stop submit_bls_change && sudo docker container prune -f

read -p "Press enter to continue..."
echo "Done"
