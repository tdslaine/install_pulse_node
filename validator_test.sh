#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Setting up Lighthouse-Validator now"
echo ""

read -p "Is this a first-time setup or are you adding to an existing setup? (1: first-time, 2: existing) " setup_choice

if [[ "$setup_choice" == "2" ]]; then
    echo -e "${RED}! To add a key, stop any running validator first!"
    echo -e "1. List validator: 'sudo docker ps'"
    echo -e "2. Stop instance: 'sudo docker stop VALIDATOR_NAME'"
    echo -e "After you have successfully imported your validator key please restart your validator by running ./start_validator.sh."${NC}

    read -p "Have you stopped all running instances of the validator? (y/N): " stopped_instances
    if [[ "$stopped_instances" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Proceeding with adding the key..."
    else
        echo "Please stop all running instances before continuing."
        exit 1
    fi
else
    echo "Proceeding with first-time setup..."
fi

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
    echo ""
    echo "Required packages are already installed."
    echo ""
fi

# Create the lhvalidator user with no home directory and add it to the docker group
sudo useradd -MG docker validator

# Enable tab autocompletion for the read command if line editing is enabled
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
  bind '"\t":menu-complete'
fi

# Define the custom path for the validator directory
read -e -p  " > Enter the path to store validator data (default: /blockchain):" custompath

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
    echo ""
    echo "Importing pre-existing validator_keys:"
    echo ""
    echo -e "Enter the path to the directory with your 'validator_keys' backup."
    echo -e "Make sure it's unzipped and available. Use tab-autocomplete when entering the path."
    echo -e "This could be an external folder, e.g., /media/username/USB_drive_name"
    read -e -p "(default: /backupPath):" backup_path
       
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
            echo "Source and destination paths match. Skipping restore; keys seem already in place."
            echo "Key import will still proceed..."
        fi
    else
        echo "Source directory does not exist. Please check the provided path and try again. Now exiting"
        exit 1
    fi
fi
    # Ask the user if they want to generate a new key after importing
read -e -p "Do you want to generate a new validator_key? (y/n) [n]: " generate_new_key
# Set the default value for generating a new key if the user enters nothing
if [ -z "$generate_new_key" ]; then
  generate_new_key="n"
fi
    
if ! [[ "$has_previous_key" =~ ^[Yy]$ ]] || [[ "$generate_new_key" =~ ^[Yy]$ ]]; then
    # Run the deposit.sh script
    echo "Now generating the validator keys - please follow the instructions and make sure to READ! everything"
    sudo ./deposit.sh new-mnemonic --mnemonic_language=english --chain=pulsechain-testnet-v4 --folder="${custompath}"
    cd "${custompath}"

echo ""
echo "Upload your 'deposit_data-xxxyyyzzzz.json' to https://launchpad.v4.testnet.pulsechain.com after the full chain sync. Uploading before completion may result in slashing."
sleep 5
echo ""

fi


# Ask the user to enter the fee-receiption address
echo ""
echo "Enter fee-receipt address (leave blank for my address; change later in start_validator.sh):"
echo ""
read fee_wallet
echo ""

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
echo ""
echo "Please enter your desired graffiti (default: HexForLife_${random_number}):"
read user_graffiti

# Set the default value for graffiti if the user enters nothing
if [ -z "$user_graffiti" ]; then
    user_graffiti="HexForLife_${random_number}"
fi

echo "Using graffiti: ${user_graffiti}"
echo ""

echo "Importing validator_keys using the lighthouse-client"
echo ""

## Run the Lighthouse Pulse docker container as the validator user
sudo docker run -it \
    --name validator_import \
    --network=host \
    -v ${custompath}:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
    lighthouse \
    --network=pulsechain_testnet_v4 \
    account validator import \
    --directory=/blockchain/validator_keys \
    --datadir=/blockchain

sudo docker stop -t 10 validator_import

sudo docker container prune

VALIDATOR_LH="sudo -u validator docker run -it --network=host --restart=always \\
    -v ${custompath}:/blockchain \\
    --name validator \\
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
    lighthouse vc \\
    --network=pulsechain_testnet_v4 \\
    --validators-dir=/blockchain/validators \\
    --suggested-fee-recipient=${fee_wallet} \\
    --graffiti='${user_graffiti}' \\
    --beacon-nodes=http://127.0.0.1:5052 "

echo ""
echo -e "Creating the start_validator.sh script with the following contents:\n${VALIDATOR_LH}"
echo ""

# Use a heredoc to create the start_validator.sh file
sudo bash -c "cat << EOF > '${custompath}/start_validator.sh'
#!/bin/bash
${VALIDATOR_LH}
EOF"

cd ${custompath}
sudo chmod +x "${custompath}/start_validator.sh"

# Change the ownership of the custompath/validator directory to validator user and group
sudo chown -R validator:validator "${custompath}"
sudo chmod -R 644 "${custompath}/validator_keys"

echo ""
echo " - start_execution.sh, start_consensus.sh, and start_validator.sh created successfully"
echo ""
echo -e "${GREEN} - To begin syncing Pulse chain, start the execution and consensus clients by running ./start_execution.sh and ./start_consensus.sh respectively.${NC}"
echo -e "${GREEN} - Access the script directory by entering cd \"$custompath\" in your terminal.${NC}"
echo -e "${GREEN} - Once the chain is fully synced, start the validator client with ./start_validator.sh.${NC}"
echo ""
echo " - Please run each start script once; Docker containers auto-restart on reboot/crashes afterward."
echo " - View logs using ./log_viewer.sh (Ubuntu GUI) or tmux_logviewer.sh (terminal-based only)."
echo ""
echo " - Note: Sync the chain fully before starting the validator, and avoid using the same keys on multiple machines."
echo ""
echo " - For errors, check running docker images with \"sudo docker ps\". Stop them with \"sudo docker stop ID-NUMBER or NAME\"."
echo " - Prune the container using \"sudo docker container prune\" if needed."
echo ""
echo " - Find more information in the repository's README."
echo ""
echo ""
echo -e "${GREEN} - Congratulations, installation/setup is now complete.${NC}"
echo ""
echo -e "${GREEN} ** If you found this script helpful and would like to show your appreciation, donations are accepted via ERC20 at the following address: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA ** ${NC}"
