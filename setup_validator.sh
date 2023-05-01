#!/bin/bash

start_dir=$(pwd)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

LAUNCHPAD_URL="https://launchpad.v4.testnet.pulsechain.com"
DEPOSIT_CLI_NETWORK="pulsechain-testnet-v4"
LIGHTHOUSE_NETWORK_FLAG="pulsechain_testnet_v4"
PRYSM_NETWORK_FLAG="pulsechain-testnet-v4"


function_get_user_choices() {
    echo "Choose your Validator Client"
    echo "based on your consensus/beacon Client"
    echo ""
    echo "1. Lighthouse (Authors choice)"
    echo "2. Prysm"
    echo ""
    read -p "Enter your choice (1 or 2): " client_choice

    echo ""
    echo "Is this a first-time setup or are you adding to an existing setup?"
    echo ""
    echo "1. First-Time Validator Setup"
    echo "2. Add or Import to an Existing setup"
    echo "" 
    read -p "Enter your choice (1 or 2): " setup_choice

    echo "${client_choice} ${setup_choice}"
}

function press_enter_to_continue(){
    echo "Press Enter to continue"
    read -p ""
}

function_stop_validator(){
    echo "Shutting down current Validator Processes to continue Setup"
    function_press_enter_to_continue
    sudo docker stop validator
    sudo docker rm validator
    sudo docker container prune -f
}

function_display_credits() {
    echo ""
    echo "Brought to you by:"
    echo "  ██████__██_██████__███████_██_______█████__██____██_███████_██████__"
    echo "  ██___██_██_██___██_██______██______██___██__██__██__██______██___██_"
    echo "  ██___██_██_██████__███████_██______███████___████___█████___██████__"
    echo "  ██___██_██_██___________██_██______██___██____██____██______██___██_"
    echo "  ██████__██_██______███████_███████_██___██____██____███████_██___██_"
    echo -e "${GREEN}For Donations use \nERC20: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA${NC}"
    echo ""
}

function_tab_autocomplete(){
    
    # Enable tab autocompletion for the read command if line editing is enabled
    if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
        bind '"\t":menu-complete'
    fi
}

function_common_task_software_check(){


    # Check if req. software is installed
    python_check=$(python3.10 --version 2>/dev/null)
    docker_check=$(docker --version 2>/dev/null)
    docker_compose_check=$(docker-compose --version 2>/dev/null)
    
    # Install the req. software only if not already installed
    if [[ -z "${python_check}" || -z "${docker_check}" || -z "${docker_compose_check}" ]]; then
        echo "Installing required packages..."
        sudo add-apt-repository ppa:deadsnakes/ppa -y
    
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo \
        "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
        sudo apt-get update -y
        sudo apt-get upgrade -y
        sudo apt-get dist-upgrade -y
        sudo apt autoremove -y
    
        sudo apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            git \
            ufw \
            openssl \
            lsb-release \
            python3.10 python3.10-venv python3.10-dev python3-pip \
            docker-ce docker-ce-cli containerd.io docker-compose
    
    else
        echo ""
        echo "Required packages are already installed."
        echo ""
    fi
}

function graffiti_setup() {
    random_number=$(shuf -i 1000-9999 -n 1)
    echo ""
    read -e -p "$(echo -e "${GREEN}Please enter your desired graffiti. Ensure that it does not exceed 32 characters (default: DipSlayer_${random_number}):${NC}")" user_graffiti

    # Set the default value for graffiti if the user enters nothing
    if [ -z "$user_graffiti" ]; then
        user_graffiti="DipSlayer_${random_number}"
    fi

    echo ""
    echo " - Using graffiti: ${user_graffiti}"
    echo ""
}

function_set_install_path() {
    read -e -p "$(echo -e "${GREEN}Please specify the directory for storing validator data (default: /blockchain):${NC} ")" INSTALL_PATH
    if [ -z "$INSTALL_PATH" ]; then
        INSTALL_PATH="/blockchain"
    fi

    if [ ! -d "$INSTALL_PATH" ]; then
        sudo mkdir -p "$INSTALL_PATH"
        echo "Created the directory: $INSTALL_PATH"
    else
        echo "The directory already exists: $INSTALL_PATH"
    fi
}

function_get_active_network_device() {
     interface=$(ip route get 8.8.8.8 | awk '{print $5}')
     echo "Your online network interface is: $interface"
}

function cd_into_staking_cli() {
    cd ${INSTALL_PATH}/staking-deposit-cli
    sudo python3 setup.py install > /dev/null 2>&1
}

function_network_interface_DOWN() {
    function_get_active_network_device
    echo "Shutting down Network-Device ${interface} ..."
    sudo ip link set $interface down
    echo "The network interface has been shutdown. It will be put back online after this process."

}

function start_scripts_first_time() {
    # Check if the user wants to run the scripts
    read -e -p "Do you want to run the scripts to start execution, consensus, and validator? (y/n) " choice
    if [[ "$choice" =~ ^[Yy]$ || "$choice" == "" ]]; then
        # Generate the commands to start the scripts
        commands=(
            "sudo ${INSTALL_PATH}/start_execution.sh > /dev/null 2>&1 &"
            "sudo ${INSTALL_PATH}/start_consensus.sh > /dev/null 2>&1 &"
            "sudo ${INSTALL_PATH}/start_validator.sh > /dev/null 2>&1 &"
        )

        # Run the commands
        for cmd in "${commands[@]}"; do
            echo "Running command: $cmd"
            eval "$cmd"
            sleep 1
        done
    fi
}

function clear_bash_history() {
    echo "Clearing bash history now..."
    history -c && history -w
    echo "Bash history cleared!"
}

function_network_interface_UP() {
    echo "Restarting Network-Interface ${interface} ..."
    sudo ip link set $interface up
    echo "Network interface put back online"
}

function_create_user() {
    target_user=$1
    if id "$target_user" >/dev/null 2>&1; then
        echo "User $target_user already exists."
    else
        sudo useradd -MG docker "$target_user"
        echo "User $target_user has been created and added to the docker group."
    fi
}

function clone_staking_deposit_cli() {
    target_directory=$1

    # Removing existing Staking -Cli folder so we get the latest...
    sudo rm -rf "${target_directory}/staking-deposit-cli"

    # Clone the staking-deposit-cli repository
    sudo git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git "${target_directory}/staking-deposit-cli"
    echo "Cloned staking-deposit-cli repository into ${target_directory}/staking-deposit-cli"
}

function Staking_Cli_launch_setup() {
    # Check Python version (>= Python3.8)
    echo "running staking-cli Checkup"
    cd "${INSTALL_PATH}/staking-deposit-cli"
    python3_version=$(python3 -V 2>&1 | awk '{print $2}')
    required_version="3.8"

    if [ "$(printf '%s\n' "$required_version" "$python3_version" | sort -V | head -n1)" = "$required_version" ]; then
        echo "Python version is greater or equal to 3.8"
    else
        echo "Error: Python version must be 3.8 or higher"
        exit 1
    fi

    sudo pip3 install -r "${INSTALL_PATH}/staking-deposit-cli/requirements.txt" > /dev/null 2>&1
    #read -p "debug 1" 
    sudo python3 "${INSTALL_PATH}/staking-deposit-cli/setup.py" install > /dev/null 2>&1
    #read -p "debug 2"
}


function_create_subfolder() {
    subdirectory=$1
    sudo mkdir -p "${INSTALL_PATH}/${subdirectory}"
    sudo chmod 777 "${INSTALL_PATH}/${subdirectory}"
    echo "Created directory: ${install_path}/${subdirectory}"
}


function_create_prysm_wallet_password() {
    password_file="${INSTALL_PATH}/wallet/pw.txt"

    if [ -f "$password_file" ]; then
        echo ""
        echo -e "${RED}Warning: A password file already exists at ${password_file}${NC}"
        echo ""
        read -n 1 -p "Do you want to continue and overwrite the existing password file? (y/n) [n]: " confirm
        if [ "$confirm" != "y" ]; then
            echo "Cancelled password creation."
            return
        fi
    fi

    echo "" 
    echo ""
    echo -e "Please create your Prysm Wallet password now."
    echo ""
    echo "This has nothing to do with the 24-word SeedPhrase that Staking-Cli will output."
    echo "Unlocking your wallet is necessary for the Prysm Validator Client. In the next step, we will point the keys created with staking-cli to the unlocked wallet."
    echo ""
    while true; do
        echo "Please enter a password (must be at least 8 characters):"
        read -s password
        if [[ ${#password} -ge 8 ]]; then
            break
        else
            echo "Error: Password must be at least 8 characters long."
        fi
    done
    echo "$password" > "$password_file"
}

function check_and_pull_lighthouse() {
    # Check if the Lighthouse validator Docker image is present
    lighthouse_image_exists=$(sudo docker images registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest -q)

    # If the image does not exist, pull the image
    if [ -z "$lighthouse_image_exists" ]; then
        echo "Lighthouse validator Docker image not found. Pulling the latest image..."
        sudo docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
    else
        echo "Lighthouse validator Docker image is already present."
    fi
}

function check_and_pull_prysm_validator() {
    # Check if the Prysm validator Docker image is present
    prysm_image_exists=$(sudo docker images registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest -q)

    # If the image does not exist, pull the image
    if [ -z "$prysm_image_exists" ]; then
        echo "Prysm validator Docker image not found. Pulling the latest image..."
        sudo docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest
    else
        echo "Prysm validator Docker image is already present."
    fi
}

function stop_and_prune_validator_import(){
    sudo docker stop validator_import > /dev/null 2>&1
    sudo docker prune -f > /dev/null 2>&1
}

function stop_docker_image(){
    echo "To import the keys into an existing setup, we need to stop the running validator Docker image."
    image =$1
    sudo docker stop ${image} > /dev/null 2>&1
    sudo docker prune -f > /dev/null 2>&1
}

function start_script(){
    target=$1
    echo -e "Restarting ${target}"
    bash "${INSTALL_PATH}/start_${target}.sh"
}


function import_lighthouse_validator() {
    stop_and_prune_validator_import
    docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
    sudo docker run -it \
        --name validator_import \
        --network=host \
        -v ${INSTALL_PATH}:/blockchain \
        -v ${INSTALL_PATH}/validator_keys:/keys \
        registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
        lighthouse \
        --network=${LIGHTHOUSE_NETWORK_FLAG} \
        account validator import \
        --directory=/keys \
        --datadir=/blockchain
    stop_and_prune_validator_import
}

function import_prysm_validator() {
    stop_and_prune_validator_import
    docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest
    if [ -f "${INSTALL_PATH}/wallet/direct/accounts/all-accounts.keystore.json" ]; then
        sudo chmod -R 0600 "${INSTALL_PATH}/wallet/direct/accounts/all-accounts.keystore.json"
    fi
    docker run --rm -it \
        --name validator_import \
        -v $INSTALL_PATH/validator_keys:/keys \
        -v $INSTALL_PATH/wallet:/wallet \
        registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest \
        accounts import \
        --${PRYSM_NETWORK_FLAG} \
        --keys-dir=/keys \
        --wallet-dir=/wallet \
        --wallet-password-file=/wallet/pw.txt
    stop_and_prune_validator_import
}



function deposit_upload_info() {

    echo ""
    echo -e "Upload your 'deposit_data-xxxyyyzzzz.json' to ${LAUNCHPAD_URL} after the full chain sync. ${RED}Uploading before completion may result in slashing.${NC}"
    echo ""
    echo -e "${RED}For security reasons, it's recommended to store the validator_keys in a safe, offline location after importing it.${NC}"
    echo ""
    press_enter_to_continue
}

function warn_network() {

    echo ""
    echo "For better security, it is highly recommended to generate new keys or restore them from a seed phrase (mnemonic) offline."
    echo ""
    echo -e "${RED}WARNING: Disabling your network interface may result in loss of remote"
    echo -e "         access to your machine. Ensure you have an alternative way to"
    echo -e "         access your machine, such as a local connection or a remote"
    echo -e "         VPS terminal, before proceeding."
    echo -e ""
    echo -e "IMPORTANT: Proceed with caution, as disabling the network interface"
    echo -e "           without any other means of access may leave you unable to"
    echo -e "           access your machine remotely. Make sure you fully understand"
    echo -e "           the consequences and have a backup plan in place before taking"
    echo -e "           this step.${NC}"

    echo ""
    echo -e "Would you like to disable the network interface during the key"
    echo -e "generation process? This increases security, but ${RED}may affect remote"
    echo -e "access currently${NC}"
    echo ""
    read -e -p "Please enter 'y' to confirm or 'n' to decline (default: n): " network_off
    network_off=${network_off:-n}

}


function get_fee_receipt_address() {
    read -e -p "$(echo -e "${GREEN}Enter fee-receipt address (leave blank for default address; change later in start_validator.sh):${NC}")" fee_wallet
    echo ""
    # Use a regex pattern to validate the input wallet address
    if [[ -z "${fee_wallet}" ]] || ! [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        fee_wallet="0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA"
        echo " - Using default fee-receiption address: ${fee_wallet}"
    else
        echo " - Using provided fee-receiption address: ${fee_wallet}"
    fi
}





# Start Validator Setup
clear

echo "Setting up the Validator now"

press_enter_to_continue

# User Menu to Choose Client and Setup-Type
function_get_user_choices

# Add Tab-Autocomplete
function_tab_autocomplete

# Checking for installed/Required software
function_common_task_software_check

# Add "validator" user to system and docker-grp
function_create_user "validator"

# Prompt User for Set up installation path
function_set_install_path


# Cloning staking Client into installation path
#echo "debug :  cloning staking client"
clone_staking_deposit_cli "${INSTALL_PATH}"
#echo "debug : cloning staking client"

# Create PRYSM-Wallet pw.txt if First-Time Setup and User choose Prysm-Client

    if [[ "$setup_choice" == "1" ]]; then
        if [[ "$client_choice" == "2" ]]; then

            function_create_subfolder "wallet"
            function_create_prysm_wallet_password
        fi
    fi 


Staking_Cli_launch_setup                       # Checking requirements and setting up StakingCli

sudo chmod -R 777 "${INSTALL_PATH}"

clear

echo ""

# Functions for the three key options 
import_restore_validator_keys() {

    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    if [[ "$setup_choice" == "2" ]]; then
    function_stop_validator
    fi


    while true; do
    
        # Prompt the user to enter the path to the root directory containing the 'validator_keys' backup-folder
        echo -e "Enter the path to the root directory which contains the 'validator_keys' backup-folder."
        echo -e "For example, if your 'validator_keys' folder is located in '/home/user/my_backup/validator_keys',"
        echo -e "then provide the path '/home/user/my_backup'. You can use tab-autocomplete when entering the path."
        read -e -p "Path to backup: " backup_path
    
        # Check if the source directory exists
        if [ -d "${backup_path}/validator_keys" ]; then
            # Check if the source and destination paths are different
            if [ "${INSTALL_PATH}/validator_keys" != "${backup_path}/validator_keys" ]; then
                # Copy the validator_keys folder to the install path
                sudo cp -R "${backup_path}/validator_keys" "${INSTALL_PATH}"
                # Inform the user that the keys have been successfully copied over
                echo "Keys successfully copied."
                # Exit the loop
                break
            else
                # Inform the user that the source and destination paths match and no action is needed
                echo "Source and destination paths match. Skipping restore-copy; keys seem already in place."
                echo "Key import will still proceed..."
                # Exit the loop
                break
            fi
        else
            # Inform the user that the source directory does not exist and ask them to try again
            echo "Source directory does not exist. Please check the provided path and try again."
        fi
    done
    
        
    
    echo "Importing validator keys now"
    
    if [[ "$client_choice" == "1" ]]; then
        import_lighthouse_validator
        elif [[ "$client_choice" == "2" ]]; then
        import_prysm_validator
    fi
    
    if [[ "$setup_choice" == "2" ]]; then          
    start_script validator
    echo "Import into existing Setup done."
    press_enter_to_continue

    exit 0
    fi
            
}


# Function to restore from SeedPhrase 
Restore_from_MN() {

    echo "Restoring validator_keys from SeedPhrase (Mnemonic)"

    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    if [[ "$setup_choice" == "2" ]]; then
       function_stop_validator
    fi
    
    warn_network                                    # Print Warning Message for Network 

    if [[ "$network_off" =~ ^[Yy]$ ]]; then         # Stop Network Interface
        function_get_active_network_device
        function_network_interface_DOWN
    fi

    echo "Now running staking-cli command to restore from your SeedPhrase (Mnemonic)"
    echo ""
    #echo "debug The current directory is: $(pwd)"
    cd "${INSTALL_PATH}/staking-deposit-cli"
    #echo "debug The current directory is: $(pwd)"
    
    ./deposit.sh existing-mnemonic --chain=${DEPOSIT_CLI_NETWORK} --folder="${INSTALL_PATH}" 
    #echo "debug The current directory is: $(pwd)"
    cd "${INSTALL_PATH}"

  
    if [[ "$network_off" =~ ^[Yy]$ ]]; then         # Restart Network Inteface
       function_network_interface_UP
    fi 

    if [[ "$client_choice" == "1" ]]; then      # User choose Lighthouse
    import_lighthouse_validator                 # import using Lighthouse
    elif [[ "$client_choice" == "2" ]]; then    # User choose Prysm
    import_prysm_validator                      # import using prysm
    fi
    
    if [[ "$setup_choice" == "2" ]]; then          
    start_script validator
    echo "Import into existing Setup done."
    press_enter_to_continue
    exit 0
    fi
}
    
# Function to generate a new validator key 
generate_new_validator_key() {

    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    if [[ "$setup_choice" == "2" ]]; then
    function_stop_validator
    fi

    warn_network

    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        function_network_interface_DOWN
    fi


    echo ""
    echo "Generating the validator keys via staking-cli now..."
    echo ""
    echo "Please follow the instructions and make sure to READ! and understand everything on screen"
    echo ""

    echo ""
    echo "Please enter the wallet address that you would like to use for receiving"
    echo "validator rewards while validating and withdrawing your funds when you exit the validator pool."
    echo ""
    echo "Please note that this address must be a valid PRC20 address."
    echo ""
    echo -e "${RED}Once set, it cannot be changed, so please double-check that you have entered the correct address.${NC}"
    echo ""
    echo "I have read this information and confirm that I understand the importance of"
    echo "using the right Withdrawal-Wallet Address. Press Enter to continue."
    read -e -p "" confirm

    if [[ -z "$confirm" ]]; then
        echo "Thank you for confirming."
    else
            echo "Please read the information carefully and confirm by pressing Enter. Exiting script."
        exit 1
    fi


    echo -e "${RED}Also make sure you have full access to this Wallet! Again, once set it cannot be changed${NC}"
    echo ""

    # Check if the Adress is a valid Adress, loop until it is.
    while true; do
    read -e -p "Please enter your Withdrawal-Wallet adress: " withdrawal_wallet
    if [[ "${withdrawal_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        break
    else
        echo "Invalid address format. Please enter a valid PRC20 address."
    fi
    done

    # Running staking-cli to Generate the new validator_keys
    echo ""
    echo "Now running staking-cli to Generate the new validator_keys"
    echo ""

    sudo ${INSTALL_PATH}/staking-deposit-cli/deposit.sh new-mnemonic \
    --mnemonic_language=english \
    --chain=${DEPOSIT_CLI_NETWORK} \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address=${withdrawal_wallet}

    #echo "debug The current directory is: $(pwd)"
    cd "${INSTALL_PATH}"
    sudo chmod -R 777 validator_keys
    #echo "debug The current directory is: $(pwd)"

    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        function_network_interface_UP
    fi

    if [[ "$client_choice" == "1" ]]; then
        import_lighthouse_validator
    elif [[ "$client_choice" == "2" ]]; then
        import_prysm_validator
    fi


    if [[ "$setup_choice" == "2" ]]; then        
        start_script validator
        echo "Import into existing Setup done."
        press_enter_to_continue
        exit 0
    fi
    
}

# Selection menu for validator_keys
PS3="Choose an option (1-3): "
options=("Generate new validator_keys" "Import/Restore validator_keys from a backup-folder" "Restore validator_keys from SeedPhrase (Mnemonic)")
select opt in "${options[@]}"

do
    case $REPLY in
        1)
            generate_new_validator_key
            break
            ;;
        2)
            import_restore_validator_keys
            break
            ;;
        3)
            Restore_from_MN
            break
            ;;  
        *)
            echo "Invalid option. Please choose option (1-3)."
            ;;
    esac
done


# Code from here is for fresh-install only to generate the start_validator.sh launch script.

if [[ "$setup_choice" == "1" ]]; then

echo "Gathering data for the Validator-Client, data will be used to generate the start_validator script"


get_fee_receipt_address             # Set Fee-Receipt address

graffiti_setup                      # Set Graffiti 


## Defining the start_validator.sh script content, this is only done during the "first-time-setup"

if [[ "$client_choice" == "1" ]]; then
    VALIDATOR="
    sudo -u validator docker run -dt --network=host --restart=always \\
    -v "${INSTALL_PATH}":/blockchain \\
    --name validator \\
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
    lighthouse vc \\
    --network=${LIGHTHOUSE_NETWORK_FLAG} \\
    --validators-dir=/blockchain/validators \\
    --suggested-fee-recipient="${fee_wallet}" \\
    --graffiti="${user_graffiti}" \\
    --metrics \\
    --beacon-nodes=http://127.0.0.1:5052 "

elif [[ "$client_choice" == "2" ]]; then 
VALIDATOR="
sudo -u validator docker run -dt --network=host --restart=always \\
-v "${INSTALL_PATH}"/wallet:/wallet \\
-v "${INSTALL_PATH}"/validator_keys:/keys \\
--name=validator \\
registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest --${PRYSM_NETWORK_FLAG} \\
--suggested-fee-recipient="${fee_wallet}" \\
--wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt \\
--graffiti "${user_graffiti}" --rpc " 

else 
    echo "Error - Debugging required"

fi

echo ""
echo "debug info:"
echo -e "Creating the start_validator.sh script with the following contents:\n${VALIDATOR}"
echo ""

if [[ "$network_off" =~ ^[Yy]$ ]]; then         # Restarting Network interface should it still be down for some reason
    function_network_interface_UP
fi

sudo chmod -R 777 ${INSTALL_PATH}

#echo "Current directory is $(pwd)"

# Writing the start_validator.sh script, this is only done during "first-setup"
cat > "${INSTALL_PATH}/start_validator.sh" << EOL
#!/bin/bash

${VALIDATOR}
EOL

sudo chmod +x "${INSTALL_PATH}/start_validator.sh"

sleep 3

# Change the ownership of the INSTALL_PATH/validator directory to validator user and group
sudo chown -R validator:docker "$INSTALL_PATH"
sudo chmod -R 777 "$INSTALL_PATH"


# Prompt the user if they want to run the scripts
start_scripts_first_time


# Clearing the Bash-Histroy
clear_bash_history


read -e -p "$(echo -e "${GREEN}Do you want to run the Prometheus/Grafana Monitoring Setup now (y/n):${NC}")" choice

   while [[ ! "$choice" =~ ^(y|n)$ ]]; do
        read -e -p "Invalid input. Please enter 'y' or 'n': " choice
    done

if [[ "$choice" =~ ^[Yy]$ || "$choice" == "" ]]; then
    # Check if the setup_monitoring.sh script exists
    if [[ ! -f "${start_dir}/setup_monitoring.sh" ]]; then
        echo "setup_monitoring.sh script not found. Aborting Prometheus/Grafana Monitoring setup."
        exit 1
    fi
    # Set the permission and run the setup script
    sudo chmod +x "${start_dir}/setup_monitoring.sh"
    "${start_dir}/setup_monitoring.sh"

    # Check if the setup script was successful
    if [[ $? -ne 0 ]]; then
        echo "Prometheus/Grafana Monitoring setup failed. Please try again or set up manually."
        exit 1
    fi

        exit 0
    else
    echo "Skipping Prometheus/Grafana Monitoring Setup."
fi

echo ""

read -e -p "$(echo -e "${GREEN}Do you want to start the logviewer to monitor the client logs? [y/n]:${NC}")" log_it

if [[ "$log_it" =~ ^[Yy]$ ]]; then
    cd "${INSTALL_PATH}"
    echo "Choose a log viewer:"
    echo "1. GUI/TAB Based Logviewer (serperate tabs; easy)"
    echo "2. TMUX Logviewer (AIO logs; advanced)"
    
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            "${INSTALL_PATH}/log_viewer.sh"
            ;;
        2)
            "${INSTALL_PATH}/tmux_logviewer.sh"
            ;;
        *)
            echo "Invalid choice. Exiting."
            ;;
    esac
fi

echo -e " ${RED}Note: Sync the chain fully before submitting your deposit_keys to prevent slashing; avoid using the same keys on multiple machines.${NC}"
echo ""
echo -e "Find more information in the repository's README."

#credits
function_display_credits
exit 0
fi
