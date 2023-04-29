#!/bin/bash
#
start_dir=$(pwd)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

LAUNCHPAD_URL="https://launchpad.v4.testnet.pulsechain.com"
DEPOSIT_CLI_NETWORK="pulsechain-testnet-v4"
LIGHTHOUSE_NETWORK_FLAG="pulsechain_testnet_v4"

echo "Setting up Lighthouse-Validator now"
echo ""
    echo "Is this a first-time setup or are you adding to an existing setup?"
    echo ""
    echo "1. First-Time Validator Setup"
    echo "2. Add or Import to an Existing setup"
    echo "" 
    read -p "Enter your choice (1 or 2): " setup_choice
    

if [[ "$setup_choice" == "2" ]]; then
    echo -e "${RED}To add a key, we have to stop running lighthouse images, stoping docker images now${NC}"
    sudo docker stop validator beacon
    sudo docker rm validator beacon
    sudo docker container prune -f

else
    echo ""
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
read -e -p "$(echo -e "${GREEN}Enter the path to store validator data (default: /blockchain):${NC} ")" custompath

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

clear

# Run the helper script for installation
#./deposit.sh install
echo ""

# Functions for the two options ############################################################################
import_validator_keys() {
    # Code for importing the existing validator_keys
    echo ""
    echo "Importing pre-existing validator_keys:"
    echo ""
    echo "shutting down running validator docker-image"
    sudo docker stop validator
    sudo docker container prune -f
    echo ""
    echo -e "Enter the path to the directory with your 'validator_keys' backup."
    echo -e "Make sure it's unzipped and available. You are able to use tab-autocomplete when entering the path."
    echo -e "This could be an external folder, e.g., /media/username/USB_drive_name"
    read -e -p "(default: /backupPath):" backup_path
   
# Set the default value for backup path if the user enters nothing
    if [ -z "$backup_path" ]; then
        backup_path="/backupPath"
    fi

    # Check if the source directory exists
    if [ -d "${backup_path}/validator_keys" ]; then
        # Check if the source and destination paths are different
        if [ "${custompath}/validator_keys" != "${backup_path}/validator_keys" ]; then
            # Restore the validator_keys from the backup
            sudo cp -R "${backup_path}/validator_keys" "${custompath}"
        else
            echo "Source and destination paths match. Skipping restore-copy; keys seem already in place."
            echo "Key import will still proceed..."
        fi
    else
        echo "Source directory does not exist. Please check the provided path and try again. Now exiting"
        exit 1
    fi
    if [[ "$setup_choice" == "2" ]]; then
    echo "Importing keys via Lighthouse-Clinet now"

#   ## Run the Lighthouse Pulse docker container as the validator user
    sudo docker run -it \
    --name validator_import \
    --network=host \
    -v ${custompath}:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
    lighthouse \
    --network=${LIGHTHOUSE_NETWORK_FLAG} \
    account validator import \
    --directory=${custompath}\
    --datadir=${custompath}
    

sudo docker stop -t 10 validator_import

sudo docker container prune -f
echo "restarting validator docker-image"
echo 
sudo ${custompath}/start_validator.sh
echo ""
echo "done."
exit 0
fi
}

generate_new_validator_key() {
    # Code for generating a new validator key
    # Detect and shutdown current Network device that is connected to the internet
    interface=$(ip route get 8.8.8.8 | awk '{print $5}')

    echo ""
    echo -e "Generating your validator keys offline is a good security practice. "
    echo ""
    echo -e "${RED}However, be aware that if you turn off your network interface, you will lose remote access to your machine. Make sure you are locally present on the machine before doing so.${NC}"
    echo ""
    read -e -p "Do you want to shutdown the network interface during the keygeneration process now? (y/n)" network_off

    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        sudo ip link set $interface down
        echo "Interface $interface has been shutdown and will be put back online after the Key-generating Process"
    fi

    echo ""
    echo "Now generating the validator keys - please follow the instructions and make sure to READ! everything"
    sleep 3
    while true; do 
    echo ""
    read -e -p "$(echo -e " ${GREEN}Please enter your ETH-Withdrawal-Wallet Adress:${NC}")" withdraw_wallet
    echo ""    
    echo -e "${RED}Make sure you have full access to this Wallet!${NC}"
    # Use a regex pattern to validate the input wallet address
    if [[ -z "${withdraw_wallet}" ]] || ! [[ "${withdraw_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    echo "Please enter a valid withdrawal Wallet..."
    else
    break
    fi
    done
   
    sudo ./deposit.sh new-mnemonic --mnemonic_language=english --chain=${DEPOSIT_CLI_NETWORK} --folder="${custompath}" --eth1_withdrawal_address=${withdraw_wallet}
    cd "${custompath}"
    
    echo ""
    echo -e "Upload your 'deposit_data-xxxyyyzzzz.json' to ${LAUNCHPAD_URL} after the full chain sync. Uploading before completion may result in slashing."
    echo ""
    echo -e "${RED}For security reasons, it's recommended to store the validator_keys file in a safe, offline location after importing it.${NC}"
    echo -e "${RED}Consider removing the validator_keys folder from your local machine and storing it in a secure location, such as an offline backup or a hardware wallet.${NC}"
    echo ""
    sleep 5
    echo ""
}

# Selection menu
PS3="Choose an option (1-2): "
options=("Import existing validator_keys" "Generate new validator_key")
select opt in "${options[@]}"
do
    case $REPLY in
        1)
            import_validator_keys
            break
            ;;
        2)
            generate_new_validator_key
            break
            ;;
        *)
            echo "Invalid option. Please choose 1 or 2."
            ;;
    esac
done


# Ask the user to enter the fee-receiption address for a fresh install, skip for existing installation
if [[ "$setup_choice" == "1" ]]; then

clear
echo "Now continuing with initial Setup"
echo ""
read -e -p "$(echo -e " ${GREEN}Enter fee-receipt address (leave blank for my address; change later in start_validator.sh):${NC}")" fee_wallet
echo ""

# Use a regex pattern to validate the input wallet address
if [[ -z "${fee_wallet}" ]] || ! [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    fee_wallet="0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA"
    echo " - Using default fee-receiption address: ${fee_wallet}"
else
    echo " - Using provided fee-receiption address: ${fee_wallet}"
fi

# Generate a random number between 1000 and 9999
random_number=$(shuf -i 1000-9999 -n 1)

# Ask the user to enter their desired graffiti
echo ""
read -e -p "$(echo -e "${GREEN} Please enter your desired graffiti. Ensure that it does not exceed 32 characters (default: DipSlayer_${random_number}):${NC}")" user_graffiti

# Set the default value for graffiti if the user enters nothing
if [ -z "$user_graffiti" ]; then
    user_graffiti="DipSlayer_${random_number}"
fi

echo ""
echo " - Using graffiti: ${user_graffiti}"
echo ""

echo "Importing validator_keys using the lighthouse-client"
echo ""

## Run the Lighthouse Pulse docker container as the validator user
fi

sudo docker run -it \
    --name validator_import \
    --network=host \
    -v ${custompath}:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
    lighthouse \
    --network=${LIGHTHOUSE_NETWORK_FLAG} \
    account validator import \
    --directory=/blockchain/validator_keys \
    --datadir=/blockchain

sudo docker stop -t 10 validator_import

sudo docker container prune -f

if [[ "$setup_choice" == "1" ]]; then
VALIDATOR_LH="sudo -u validator docker run -dt --network=host --restart=always \\
    -v "${custompath}":/blockchain \\
    --name validator \\
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
    lighthouse vc \\
    --network=${LIGHTHOUSE_NETWORK_FLAG} \\
    --validators-dir=/blockchain/validators \\
    --suggested-fee-recipient="${fee_wallet}" \\
    --graffiti="${user_graffiti}" \\
    --metrics \\
    --beacon-nodes=http://127.0.0.1:5052 "

echo ""
echo "debug info:"
echo -e "Creating the start_validator.sh script with the following contents:\n${VALIDATOR_LH}"
echo ""
echo "Restarting Network-Interface..."

if [[ "$network_off" =~ ^[Yy]$ ]]; then
    sudo ip link set $interface up
fi
echo "Network interface put back online"
   
#write start_validator.sh
sudo chmod 777 ${custompath}

cat > start_validator.sh << EOL
${VALIDATOR_LH}
EOL

sudo chmod +x "start_validator.sh"
sudo cp start_validator.sh "$custompath"
sleep 2

# Change the ownership of the custompath/validator directory to validator user and group
sudo chown -R validator:docker "$custompath"
sudo chmod -R 777 "$custompath"

# Change docker /var/run/docker.sock permission to be able to view logs withouth being in docker grp
sudo chmod 666 /var/run/docker.sock

#debug 
#echo "${custompath}/start_validator.sh"
#echo "debug"

# Prompt the user if they want to run the scripts
read -e -p "$(echo -e "${GREEN}Would you like to start the execution, consensus and validator scripts now? [y/n]:${NC}")" choice

# Check if the user wants to run the scripts
if [[ "$choice" =~ ^[Yy]$ || "$choice" == "" ]]; then

  # Generate the command to start the scripts
  command1="sudo ${custompath}/start_execution.sh > /dev/null 2>&1 &" 
  command2="sudo ${custompath}/start_consensus.sh > /dev/null 2>&1 &"
  command3="sudo ${custompath}/start_validator.sh > /dev/null 2>&1 &"
  
  
  # Run the commands
  echo "Running command: $command1"
  eval $command1
  sleep 1
  echo "Running command: $command2"
  eval $command2
  sleep 1
  echo "Running command: $command3"
  eval $command3
  sleep 1
fi

clear
# Reset the terminal
#sudo rm -R ${custompath}/staking-deposit-cli

read -e -p "$(echo -e "${GREEN}Do you want to run the Prometheus/Grafana Monitoring Setup now (y/n):${NC}")" answer

if [[ $answer == "y" ]] || [[ $answer == "Y" ]]; then
  sudo chmod +x $start_dir/setup_monitoring.sh
  $start_dir/setup_monitoring.sh
  exit 0
else
  echo "Skipping Prometheus/Grafana Monitoring Setup."
fi

echo ""
read -e -p "$(echo -e "${GREEN}Would you like to start the logviewer to monitor the client logs? [y/n]:${NC}")" log_it

if [[ "$log_it" =~ ^[Yy]$ ]]; then
    echo "Choose a log viewer:"
    echo "1. GUI/TAB Based Logviewer (serperate tabs; easy)"
    echo "2. TMUX Logviewer (AIO logs; advanced)"
    
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            ${custompath}/./log_viewer.sh
            ;;
        2)
            ${custompath}/./tmux_logviewer.sh
            ;;
        *)
            echo "Invalid choice. Exiting."
            ;;
    esac
fi
echo -e " ${RED}Note: Sync the chain fully before submitting your deposit_keys to prevent slashing; avoid using the same keys on multiple machines.${NC}"
echo ""
echo -e "Find more information in the repository's README."
echo ""
echo "Brought to you by:
  ██████__██_██████__███████_██_______█████__██____██_███████_██████__
  ██___██_██_██___██_██______██______██___██__██__██__██______██___██_
  ██___██_██_██████__███████_██______███████___████___█████___██████__
  ██___██_██_██___________██_██______██___██____██____██______██___██_
  ██████__██_██______███████_███████_██___██____██____███████_██___██_"
echo -e "${GREEN}For Donations use ERC20: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA${NC}"
echo ""
exit 0
fi
# continuing from the existing setup
echo ""
echo "import done... restarting beacon and validator"
sudo ${custompath}/start_validator.sh
sleep 1
sudo ${custompath}/start_beacon.sh
sleep 1
echo ""
echo "done"
echo ""
exit 0
