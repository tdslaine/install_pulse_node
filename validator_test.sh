#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Now setting up the Lighthouse_validator"
echo ""

# Check if Python 3.10 is installed
python_check=$(python3.10 --version 2>/dev/null)

# Check if Docker is installed
docker_check=$(docker --version 2>/dev/null)

# Check if Docker Compose is installed
docker_compose_check=$(docker-compose --version 2>/dev/null)

# Install the required software only if not already installed
if [[ -z "${python_check}" || -z "${docker_check}" || -z "${docker_compose_check}" ]]; then
    echo "Installing required packages..."

    # Add the deadsnakes PPA repository to install the latest Python version
    sudo add-apt-repository ppa:deadsnakes/ppa -y

    # Update package lists and upgrade installed packages
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # Perform distribution upgrade and remove unused packages
    sudo apt-get dist-upgrade -y
    sudo apt autoremove -y

    # Install required packages
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        git \
        ufw \
        openssl \
        lsb-release \
        python3.10 python3.10-venv python3.10-dev python3-pip

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y

    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

else
    echo "Required packages are already installed."
fi

# Create the lhvalidator user with no home directory and add it to the docker group
sudo useradd -MG docker validator

# Enable tab autocompletion for the read command if line editing is enabled
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
  bind '"\t":menu-complete'
fi

# Define the custom path for the validator directory
read -e -p  "please enter the path for the validator data like keys, pw etc.. (default: /blockchain):" custompath

# Set the default value for custom path if the user enters nothing
if [ -z "$custompath" ]; then
  custompath="/blockchain"
fi

# Create the validator directory in the custom path
sudo mkdir -p "${custompath}"

# Change to the newly created validator directory
cd "${custompath}"

# Clone the staking-deposit-cli repository
sudo git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git

# Change to the staking-deposit-cli directory
cd staking-deposit-cli

# Check Python version (>= Python3.8)
python3_version=$(python3 -V 2>&1 | awk '{print $2}')
required_version="3.8"

if [ "$(printf '%s\n' "$required_version" "$python3_version" | sort -V | head -n1)" = "$required_version" ]; then
    echo "Python version is greater or equal to 3.8"
else
    echo "Error: Python version must be 3.8 or higher"
    exit 1
fi

# Install dependencies
sudo pip3 install -r requirements.txt

# Install the package
sudo python3 setup.py install

# Run the helper script for installation
#./deposit.sh install
echo ""
# Ask the user if they have previously created a validator_key
echo "Do you already have a validator_key and want to IMPORT it instead of creating a new one? (y/n)"
read has_previous_key
echo ""

if [[ "$has_previous_key" =~ ^[Yy]$ ]]; then
    read -e -p "Please enter the path to the source folder containing your 'validator_key' folder, which needs to be imported (ensure that the 'validator_key' folder is present in the source directory, and not zipped or archived. Default location: /backupPath):" backup_path
    
    # Set the default value for backup path if the user enters nothing
    if [ -z "$backup_path" ]; then
        backup_path="/backup"
    fi

    # Check if the source directory exists
    if [ -d "${backup_path}/validator_keys" ]; then
        # Check if the source and destination paths are different
        if [ "${custompath}/validator_keys" != "${backup_path}/validator_keys" ]; then
            # Restore the validator_keys from the backup
            sudo cp -R "${backup_path}/validator_keys" "${custompath}/validator_keys"
        else
            echo "Source and destination paths are the same. Skipping the restore operation."
        fi
    else
        echo "Source directory does not exist. Please check the provided path and try again. Now exiting"
        exit 1
    fi
else
    # Run the deposit.sh script with the entered fee-receiption address
    echo "Now generating the validator keys - please follow the instructions and make sure to READ! everything"
    sudo ./deposit.sh new-mnemonic --mnemonic_language=english --chain=pulsechain-testnet-v3 --folder="${custompath}"
    cd "${custompath}"

echo ""
echo "please upload your generated "deposit_data-xxxyyyzzzz.json" to the validator dashboard at https://launchpad.v3.testnet.pulsechain.com; Upload the deposit_xxxx.json only after you completed the full chain sync process - otherwise youll might get slashed."
#echo "now sleeping for 10"
sleep 5
echo ""

fi


# Ask the user to enter the fee-receiption address
echo ""
echo "Please enter the fee-receiption address (if none is entered, my adress will be used. You can change the adress later in start_validator_lh script):"
read fee_wallet

# Use a regex pattern to validate the input wallet address
if [[ -z "${fee_wallet}" ]] || ! [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    fee_wallet="0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA"
    echo "Using default fee-receiption address: ${fee_wallet}"
else
    echo "Using provided fee-receiption address: ${fee_wallet}"
fi

# Generate a random number between 1000 and 9999
random_number=$(shuf -i 1000-9999 -n 1)

# Ask the user to enter their desired graffiti
echo "Please enter your desired graffiti (default: HexForLife_${random_number}):"
read user_graffiti

# Set the default value for graffiti if the user enters nothing
if [ -z "$user_graffiti" ]; then
    user_graffiti="HexForLife_${random_number}"
fi

echo "Using graffiti: ${user_graffiti}"


echo "importing keys using lighthouse"


## Run the Lighthouse Pulse docker container as the validator user
sudo docker run -it \
    --name validator_import \
    --network=host \
    -v ${custompath}:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
    lighthouse \
    --network=pulsechain_testnet_v3 \
    account validator import \
    --directory=/blockchain/validator_keys \
    --datadir=/blockchain

sudo docker stop -t 10 validator_import

sudo docker container prune

VALIDATOR_LH="sudo -u validator docker run -it --network=host --restart=always \\
    -v ${custompath}:/blockchain \\
    --name validator
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
    lighthouse vc \\
    --network=pulsechain_testnet_v3 \\
    --validators-dir=/blockchain/validators \\
    --suggested-fee-recipient=${fee_wallet} \\
    --graffiti='${user_graffiti}' \\
    --beacon-nodes=http://127.0.0.1:5052 "

# Use a heredoc to create the start_validator_lh.sh file
cat << EOF > start_validator_lh.sh
#!/bin/bash
${VALIDATOR_LH}
EOF
cd ${custompath}
sudo chmod +x start_validator_lh.sh

# Change the ownership of the custompath/validator directory to validator user and group
sudo chown -R validator:validator "${custompath}"
sudo chmod -R 644 "${custompath}/validator_keys"

echo -e "${GREEN}start_execution.sh, start_consensus.sh, and start_validator.sh created successfully!${NC}"
echo ""
echo -e "${GREEN}Initial node and validator setup complete! Begin syncing Pulse chain by starting execution, consensus Clients, once synced start the validator client.${NC}"
echo -e "${GREEN}Enter cd \"$custompath\" in your terminal to access the script directory.${NC}"
echo -e "${GREEN}Run ./start_execution.sh and ./start_consensus.sh  to start the clients.${NC}"
echo ""
echo -e "${GREEN} - Run each start script once; Docker container will auto-restart on reboot/crashes.${NC}"
echo -e "${GREEN} - Use ./log_viewer.sh to view and follow log files.${NC}"
echo "" 
echo -e " - Sync the chain fully before starting the validator. Don't use the same keys on multiple machines."
echo ""
echo " - For errors, check running docker images with \"sudo docker ps\". Stop them with \"sudo docker stop ID-NUMBER or NAME\"."
echo " - Prune the container using \"sudo docker container prune\" if needed."
echo ""
echo " - Find more information in the repository's README."
