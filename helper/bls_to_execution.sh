#!/bin/bash

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

echo " The following procedure will ask you the follwing: "
echo ""
echo " - Path to your Blockchain installation"
echo " - Mnemonic you used to create the validator"
echo " - Starting index for the keys you want to convert (usually 0)"
echo " - The Validator index as shown on the pls-beacon-explorer https://beacon.v4.testnet.pulsechain.com/"
echo " - BLS withdrawal-Credentials (starting with 00)"
echo " - the new execution withdrawal wallet "
echo ""
echo "Note: you can enter multiple values, sepperated with a comma"
echo "      you can get your BLS-Withdrawal Credential above or via https://launchpad.v4.testnet.pulsechain.com/en/withdrawals"
echo ""

read -e -p "Please enter your installation folder (default: /blockchain): " install_path 

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


echo "copying over the conversion files"

sudo mv ${install_path}/bls_converter/staking-deposit-cli/bls_to_execution_changes/*.json ${install_path}/bls_converter/

read -p "enter"

cd ${install_path}/bls_converter/
sudo rm -R staking-deposit-cli

sudo chmod -R 777 *.json


read -e -p "Do you wish to submit the bls-to-execution conversion to your beacon now? (y/n):" submit

if [[ $submit == "y" ]]; then

	echo "please choose your beacon client"
	echo ""
	echo "1. Lighthouse"
	echo ""
	echo "2. Prysm"
	echo ""
	read -e -p "choose 1 or 2: " client_choice
		if [[ $client_choise == "1" ]]; then
sudo -u lighthouse docker run -it \
    -v ${install_path}/bls_converter:/bls_dir \
    --name submit_bls_change \
    --network="host" \
    registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest \
    validator withdraw \
    -beacon-node-host=localhost:5052 \
    --path=/bls_dir \
    --confirm
		
		elif [[ $client_choice == "2" ]]; then
			sudo -u prysm docker run -it \
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
	echo "dont forget to submit your changes to the network via your beacon..."
	exit 0
	
sudo docker stop submit_bls_change && sudo docker container prune -f

fi
echo "done"
