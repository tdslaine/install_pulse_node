
#Vars for network:

set_network_variables() {
  if [[ $1 == "testnet" ]]; then
    CHECKPOINT="https://checkpoint.v4.testnet.pulsechain.com"
    LAUNCHPAD_URL="https://launchpad.v4.testnet.pulsechain.com"
    EXECUTION_NETWORK_FLAG="pulsechain-testnet-v4"
    PRYSM_NETWORK_FLAG="pulsechain-testnet-v4"
    LIGHTHOUSE_NETWORK_FLAG="pulsechain_testnet_v4"
    DEPOSIT_CLI_NETWORK="pulsechain-testnet-v4"
  else
    CHECKPOINT="https://checkpoint.pulsechain.com"
    LAUNCHPAD_URL="https://launchpad.pulsechain.com"
    EXECUTION_NETWORK_FLAG="pulsechain"
    PRYSM_NETWORK_FLAG="pulsechain"
    LIGHTHOUSE_NETWORK_FLAG="pulsechain"
    DEPOSIT_CLI_NETWORK="pulsechain"
  fi

  export CHECKPOINT
  export LAUNCHPAD_URL
  export EXECUTION_NETWORK_FLAG
  export PRYSM_NETWORK_FLAG
  export LIGHTHOUSE_NETWORK_FLAG
  export DEPOSIT_CLI_NETWORK
}
clear 
check_and_set_network_variables() {
  if [[ -z $EXECUTION_NETWORK_FLAG ]]; then
    echo ""
    echo "+-----------------+"
    echo "| Choose network: |"
    echo "+-----------------+"
    echo "| 1) Mainnet      |"
    echo "|                 |"
    echo "| 2) Testnet      |"
    echo "+-----------------+"
    echo ""
    read -p "Enter your choice (1 or 2): " -r choice
    echo ""

    case $choice in
      1)
        set_network_variables "mainnet"
        ;;
      2)
        set_network_variables "testnet"
        ;;
      *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
    esac
  fi
}




function logviewer_prompt() {
  local log_it choice

  read -e -p "$(echo -e "${GREEN}Would you like to start the logviewer to monitor the client logs? [y/n]:${NC}")" log_it

  if [[ "$log_it" =~ ^[Yy]$ ]]; then
    while true; do
      echo "Choose a log viewer:"
      echo "1. GUI/TAB Based Logviewer (serperate tabs; easy)"
      echo "2. TMUX Logviewer (AIO logs; advanced)"

      read -p "Enter your choice (1 or 2): " choice

      case $choice in
        1)
          ${INSTALL_PATH}/helper/log_viewer.sh
          break
          ;;
        2)
          ${INSTALL_PATH}/helper/tmux_logviewer.sh
          break
          ;;
        *)
          echo "Invalid choice. Please enter 1 or 2."
          ;;
      esac
    done
  fi
}

function to_valid_erc20_address() {
    local input_address="$1"
    local input_address_lowercase="${input_address,,}"  # Convert to lowercase

    # Calculate the Keccak-256 hash of the lowercase input address using openssl
    local hash=$(echo -n "${input_address_lowercase}" | openssl dgst -sha3-256 -binary | xxd -p -c 32)

    # Build the checksum address
    local checksum_address="0x"
    for ((i=0;i<${#input_address_lowercase};i++)); do
        char="${input_address_lowercase:$i:1}"
        if [ "${char}" != "${char^^}" ]; then
            checksum_address+="${input_address:$i:1}"
        else
            checksum_address+="${hash:$((i/2)):1}"
        fi
    done

    echo "$checksum_address"
}

function restart_tmux_logs_session() {
    # Check if the "logs" tmux session is running
    if tmux has-session -t logs 2>/dev/null; then
        echo "Tmux session 'logs' is running, restarting it."
        press_enter_to_continue
        start_script tmux_logviewer
        #echo "Tmux session 'logs' has been (re)started."
        # Kill the existing "logs" session
        tmux kill-session -t logs
    else
        echo "Tmux session 'logs' is not running."
    fi

}


function reboot_advice() {
    echo "Initial setup completed. To get all permissions right, it is recommended to reboot your system now ."
    read -p "Do you want to reboot now? [y/n]: " choice

    if [ "$choice" == "y" ]; then
        sudo reboot
    elif [ "$choice" == "n" ]; then
        echo "Please remember to reboot your system later."
    else
        echo "Invalid option. Please try again."
        reboot_advice
    fi
}

while getopts "rl" option; do
    case "$option" in
        r)
            sudo reboot
            ;;
        l)
            echo "Please remember to reboot your system later."
            ;;
        *)
            reboot_advice
            ;;
    esac
done

function get_user_choices() {
    echo "Choose your Validator Client"
    echo "based on your consensus/beacon Client"
    echo ""
    echo "1. Lighthouse (Authors choice)"
    echo "2. Prysm"
    echo ""
    read -p "Enter your choice (1 or 2): " client_choice

    # Validate user input for client choice
    while [[ ! "$client_choice" =~ ^[1-2]$ ]]; do
        echo "Invalid input. Please enter a valid choice (1 or 2): "
        read -p "Enter your choice (1 or 2): " client_choice
    done

    echo ""
    echo "Is this a first-time setup or are you adding to an existing setup?"
    echo ""
    echo "1. First-Time Validator Setup"
    echo "2. Add or Import to an Existing setup"
    echo "" 
    read -p "Enter your choice (1 or 2): " setup_choice

    # Validate user input for setup choice
    while [[ ! "$setup_choice" =~ ^[1-2]$ ]]; do
        echo "Invalid input. Please enter a valid choice (1 or 2): "
        read -p "Enter your choice (1 or 2): " setup_choice
    done

    #echo "${client_choice} ${setup_choice}"
}


function press_enter_to_continue(){
    echo ""
    echo "Press Enter to continue"
    read -p ""
    echo ""
}

function stop_docker_container() {
    container_name_or_id="$1"
    
    container_status=$(docker inspect --format "{{.State.Status}}" "$container_name_or_id" 2>/dev/null)
    
    if [ "$container_status" == "running" ]; then
        echo "Stopping container with name or ID: $container_name_or_id"
        sudo docker stop -t 180 "$container_name_or_id"
        sudo docker container prune -f

    elif [ -n "$container_status" ]; then
        echo "Container $container_name_or_id is not running."
    else
        echo "No container found with name or ID: $container_name_or_id"
    fi
}


function display_credits() {
    echo ""
    echo "Brought to you by:"
    echo "  ██████__██_██████__███████_██_______█████__██____██_███████_██████__"
    echo "  ██___██_██_██___██_██______██______██___██__██__██__██______██___██_"
    echo "  ██___██_██_██████__███████_██______███████___████___█████___██████__"
    echo "  ██___██_██_██___________██_██______██___██____██____██______██___██_"
    echo "  ██████__██_██______███████_███████_██___██____██____███████_██___██_"
    
    echo ""
}

function tab_autocomplete(){
    
    # Enable tab autocompletion for the read command if line editing is enabled
    if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
        bind '"\t":menu-complete'
    fi
}

function common_task_software_check(){


    # Check if req. software is installed
    python_check=$(python3.8 --version 2>/dev/null)
    docker_check=$(docker --version 2>/dev/null)
    docker_compose_check=$(docker-compose --version 2>/dev/null)
    openssl_check=$(openssl version 2>/dev/null)
    
    # Install the req. software only if not already installed
    if [[ -z "${python_check}" || -z "${docker_check}" || -z "${docker_compose_check}" || -z "${openssl_check}" ]]; then
        echo "Installing required packages..."
        sudo apt-get update -y 
        sudo apt-get install -y software-properties-common cron
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
            b2sum \
            ufw \
            openssl \
            lsb-release \
            python3.8 python3.8-venv python3.8-dev python3-pip \
            docker-ce docker-ce-cli containerd.io docker-compose
    
    else
        echo ""
        echo "Required packages are already installed."
        echo ""
    fi
}


function graffiti_setup() { 
    echo "" 
    while true; do
        read -e -p "$(echo -e "${GREEN}Please enter your desired graffiti. Ensure that it does not exceed 32 characters (default: DipSlayer):${NC}")" user_graffiti 

        # Set the default value for graffiti if the user enters nothing 
        if [ -z "$user_graffiti" ]; then 
            user_graffiti="DipSlayer" 
            break
        # Check if the input length is within the 32 character limit
        elif [ ${#user_graffiti} -le 32 ]; then
            break
        else
            echo -e "${RED}The graffiti you entered is too long. Please ensure it does not exceed 32 characters.${NC}"
        fi
    done

    # Enclose the user_graffiti in double quotes
    user_graffiti="\"${user_graffiti}\""
}
 
 

function set_install_path() {
    echo ""
    read -e -p "$(echo -e "${GREEN}Please specify the directory for storing the validator data. Press Enter to use the default (/blockchain):${NC} ")" INSTALL_PATH
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

function get_install_path() {
    echo ""
    read -e -p "$(echo -e "${GREEN}Please specify the directory where your blockchain data root folder is located. Press Enter to use the default (/blockchain): ${NC} ")" INSTALL_PATH
    if [ -z "$INSTALL_PATH" ]; then
        INSTALL_PATH="/blockchain"
    fi
}



function get_active_network_device() {
     interface=$(ip route get 8.8.8.8 | awk '{print $5}')
     echo "Your online network interface is: $interface"
}

function cd_into_staking_cli() {
    cd ${INSTALL_PATH}/staking-deposit-cli
    sudo python3 setup.py install > /dev/null 2>&1
}

function network_interface_DOWN() {
    get_active_network_device
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

function network_interface_UP() {
    echo "Restarting Network-Interface ${interface} ..."
    sudo ip link set $interface up
    echo "Network interface put back online"
}

function create_user() {
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

    # Check if the staking-deposit-cli folder already exists
    if [ -d "${target_directory}/staking-deposit-cli" ]; then
        read -p "The staking-deposit-cli folder already exists. Do you want to delete it and clone the latest version? (y/N): " confirm_delete
        if [ "$confirm_delete" == "y" ] || [ "$confirm_delete" == "Y" ]; then
            sudo rm -rf "${target_directory}/staking-deposit-cli"
        else
            echo "Skipping the cloning process as the user chose not to delete the existing folder."
            return
        fi
    fi

    while true; do
        # Clone the staking-deposit-cli repository
        if sudo git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git "${target_directory}/staking-deposit-cli"; then
            echo "Cloned staking-deposit-cli repository into ${target_directory}/staking-deposit-cli"
            sudo chown -R $main_user:docker "${target_directory}/staking-deposit-cli"
            break
        else
            echo ""
            echo "Failed to clone staking-deposit-cli repository. Please check your internet connection and try again."
            echo ""
            echo "You can relaunch the script at any time with ./setup_validator.sh from the install folder."
            echo ""
            read -p "Press 'r' to retry, any other key to exit: " choice
            if [ "$choice" != "r" ]; then
                exit 1
            fi
        fi
    done
}

function Staking_Cli_launch_setup() {
    echo "Running staking-cli setup..."

    # Ensure Python 3.8 is installed
    echo "Ensuring Python 3.8 is installed..."
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils python3.8-dev

    # Verify Python 3.8 installation
    #python3.8_version=$(python3.8 -V 2>&1)
    #if [[ $python3.8_version != "Python 3.8"* ]]; then
    #    echo "Error: Python 3.8 is not installed correctly."
    #    exit 1
    #fi
    #echo "Python 3.8 is successfully installed."

    # Check if the staking-deposit-cli folder exists
    if [ ! -d "${INSTALL_PATH}/staking-deposit-cli" ]; then
        echo "Error: staking-deposit-cli directory not found at ${INSTALL_PATH}."
        exit 1
    fi

    # Set up Python 3.8 virtual environment
    sudo chmod -R 777 ${INSTALL_PATH}/staking-deposit-cli
    echo "Setting up Python 3.8 virtual environment..."
    cd "${INSTALL_PATH}/staking-deposit-cli" || exit
    if [ ! -d "venv" ]; then
        python3.8 -m venv venv
    fi

    # Activate the virtual environment
    source venv/bin/activate

    # Install dependencies inside the virtual environment
    echo "Installing staking-deposit-cli dependencies in virtual environment..."
    pip install --upgrade pip setuptools > /dev/null 2>&1
    pip install -r requirements.txt > /dev/null 2>&1
    pip install . > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies."
        deactivate
        exit 1
    fi

    # Deactivate virtual environment
    deactivate

    # Grant necessary permissions
    echo "Granting necessary permissions..."
    sudo chmod -R 777 "${INSTALL_PATH}/staking-deposit-cli"

    echo "Staking-cli setup complete with virtual environment."
}

#function Staking_Cli_launch_setup() {
#    echo "Running staking-cli setup..."

    # Ensure Python 3.8 is installed
   # echo "Forcing installation of Python 3.8..."
   # sudo apt-get remove -y python3 python3.* python3-pip python3-venv
   # sudo apt-get purge -y python3 python3.* python3-pip python3-venv
   # sudo apt-get autoremove -y
   # sudo apt-get autoclean

#    sudo apt-get install -y software-properties-common
#    sudo add-apt-repository -y ppa:deadsnakes/ppa
#    sudo apt-get update
#    sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils python3.8-dev

    # Ensure Python 3.8 is the default python3 version
 #   echo "Configuring Python 3.8 as the default python3 version..."
 #   sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1
 #   sudo update-alternatives --set python3 /usr/bin/python3.8

    # Install pip for Python 3.8
 #   echo "Installing pip for Python 3.8..."
 #   sudo apt-get install -y python3-pip
 #   python3 -m pip install --upgrade pip setuptools

    # Verify Python 3.8 is correctly installed
  #  python3_version=$(python3 -V 2>&1 | awk '{print $2}')
  #  if [[ $python3_version != 3.8* ]]; then
  #      echo "Error: Python 3.8 is not correctly installed."
  #      exit 1
  #  fi
 #   echo "Python 3.8 setup complete."

    # Check if the staking-deposit-cli folder exists
#    if [ ! -d "${INSTALL_PATH}/staking-deposit-cli" ]; then
#        echo "Error: staking-deposit-cli directory not found at ${INSTALL_PATH}."
#        exit 1
#    fi

    # Grant necessary permissions and navigate to the folder
#    sudo chmod -R 777 "${INSTALL_PATH}/staking-deposit-cli"
#    cd "${INSTALL_PATH}/staking-deposit-cli" || exit

    # Install dependencies using pip
#    echo "Installing staking-deposit-cli dependencies..."
#    pip install -r requirements.txt > /dev/null 2>&1
#    pip install . --user > /dev/null 2>&1
#    if [ $? -ne 0 ]; then
#        echo "Error: Failed to install dependencies."
#        exit 1
#    fi

#    echo "Staking-cli setup complete."
#}

#function Staking_Cli_launch_setup() {
    # Check Python version (>= Python3.8)
#    echo "running staking-cli Checkup"
#    sudo chmod -R 777 "${INSTALL_PATH}/staking-deposit-cli"
#    cd "${INSTALL_PATH}/staking-deposit-cli"
#    python3_version=$(python3 -V 2>&1 | awk '{print $2}')
#    required_version="3.8"

#    if [ "$(printf '%s\n' "$required_version" "$python3_version" | sort -V | head -n1)" = "$required_version" ]; then
#        echo "Python version is greater or equal to 3.8"
#    else
#        echo "Error: Python version must be 3.8 or higher"
#        exit 1
#    fi

#    sudo pip3 install -r "${INSTALL_PATH}/staking-deposit-cli/requirements.txt" > /dev/null 2>&1
#    #read -p "debug 1" 
#    sudo python3 "${INSTALL_PATH}/staking-deposit-cli/setup.py" install > /dev/null 2>&1
#    #read -p "debug 2"
#}


function create_subfolder() {
    subdirectory=$1
    sudo mkdir -p "${INSTALL_PATH}/${subdirectory}"
    sudo chmod 777 "${INSTALL_PATH}/${subdirectory}"
    echo "Created directory: ${install_path}/${subdirectory}"
}

function confirm_prompt() {
    message="$1"
    while true; do
        echo "$message"
        read -p "Do you confirm? (y/n): " yn
        case $yn in
            [Yy]* )
                # User confirmed, return success (0)
                return 0
                ;;
            [Nn]* )
                # User did not confirm, return failure (1)
                return 1
                ;;
            * )
                # Invalid input, ask again
                echo "Please answer 'y' (yes) or 'n' (no)."
                ;;
        esac
    done
}



function create_prysm_wallet_password() {
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
    echo -e "Please enter your Prysm Wallet password now."
    echo ""
    echo "This has nothing to do with the 24-word SeedPhrase that Staking-Cli will output during key-generation."
    echo "Unlocking your wallet is necessary for the Prysm Validator Client to function."
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
        echo ""
        echo "Lighthouse validator Docker image not found. Pulling the latest image..."
        sudo docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
        echo ""
    else
        echo ""
        echo "Lighthouse validator Docker image is already present."
        echo ""
    fi
}

function check_and_pull_prysm_validator() {
    # Check if the Prysm validator Docker image is present
    prysm_image_exists=$(sudo docker images registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest -q)
    # If the image does not exist, pull the image
    if [ -z "$prysm_image_exists" ]; then
        echo ""
        echo "Prysm validator Docker image not found. Pulling the latest image..."
        sudo docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest
        echo ""
    else
        echo ""
    fi
}

function stop_and_prune_validator_import(){
    sudo docker stop validator_import > /dev/null 2>&1
    sudo docker container prune -f > /dev/null 2>&1
}

function stop_docker_image(){
    echo "To import the keys into an existing setup, we need to stop the running validator container first."
    image=$1
    sudo docker stop -t 300 ${image} > /dev/null 2>&1
    sudo docker prune -f > /dev/null 2>&1
}

function start_script(){
    target=$1
    echo ""
    echo -e "Restarting ${target}"
    bash "${INSTALL_PATH}/helper/${target}.sh"
    echo "${target} container restartet"
}


#function import_lighthouse_validator() {
#    stop_and_prune_validator_import
#    echo ""
#    docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
#    echo ""
#    sudo docker run -it \
#        --name validator_import \
#        --network=host \
#        -v ${INSTALL_PATH}:/blockchain \
#        -v ${INSTALL_PATH}/validator_keys:/keys \
#        registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
#        lighthouse \
#        --network=${LIGHTHOUSE_NETWORK_FLAG} \
#        account validator import \
#        --directory=/keys \
#        --datadir=/blockchain
#    stop_and_prune_validator_import
#}

function import_lighthouse_validator() {
    stop_and_prune_validator_import
    echo ""

    # Prompt the user
    echo -n "Are you importing multiple validators with the same password? (y/N): "
    read user_response

    # If nothing is entered, default to "N"
    if [ -z "$user_response" ]; then
        user_response="N"
    fi

    docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
    echo ""

    # Base command
    cmd="sudo docker run -it \
        --name validator_import \
        --network=host \
        -v ${INSTALL_PATH}:/blockchain \
        -v ${INSTALL_PATH}/validator_keys:/keys \
        registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
        lighthouse \
        --network=${LIGHTHOUSE_NETWORK_FLAG} \
        account validator import \
        --directory=/keys \
        --datadir=/blockchain"

    # Conditionally add the --reuse-password flag
    if [ "${user_response,,}" == "y" ]; then
        cmd="$cmd \
        --reuse-password"
    fi

    # Execute the command
    eval $cmd

    stop_and_prune_validator_import
}


function import_prysm_validator() {
    stop_and_prune_validator_import
    echo ""
    docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest
    docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest
    echo ""
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
    echo "Enhance security by generating new keys or restoring them from a seed phrase (mnemonic) offline."
    echo ""
    echo -e "${RED}WARNING:${NC} Disabling your network interface may result in loss of remote"
    echo -e "         access to your machine. Ensure you have an alternative way to"
    echo -e "         access your machine, such as a local connection or a remote"
    echo -e "         VPS terminal, before proceeding."
    echo -e ""
    echo -e "${RED}IMPORTANT:${NC} Proceed with caution, as disabling the network interface"
    echo -e "           without any other means of access may leave you unable to"
    echo -e "           access your machine remotely. Make sure you fully understand"
    echo -e "           the consequences and have a backup plan in place before taking"
    echo -e "           this step."

    echo ""
    echo -e "Would you like to disable the network interface during the key"
    echo -e "generation process? This increases security, but ${RED}may affect remote"
    echo -e "access temporarily${NC}"
    echo ""
    read -e -p "Please enter 'y' to confirm or 'n' to decline (default: n): " network_off
    network_off=${network_off:-n}

}


function get_fee_receipt_address() {
    while true; do
        read -e -p "$(echo -e "${GREEN}Enter fee-receipt address:${NC} ")" fee_wallet
        echo ""
        # Validate Ethereum address format (0x followed by 40 hex chars)
        if [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            echo " - Using fee-receipt address: ${fee_wallet}"
            break
        else
            echo -e "${RED}Invalid address format. Please enter a valid 0x address.${NC}"
        fi
    done
}


function get_user_choices_monitor() {
  local client_choice

  while true; do
    echo "Choose your Client"
    echo ""
    echo "1. Lighthouse"
    echo "2. Prysm"
    echo ""
    read -p "Enter your choice (1 or 2): " client_choice

    case $client_choice in
      1|2)
        break
        ;;
      *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
    esac
  done

  #echo "${client_choice}"
}

function add_user_to_docker_group() {
    # Check if the script is run as root
    if [ "$EUID" -eq 0 ]; then
        # Get the main non-root user
        local main_user=$(logname)

        # Check if the main user is already in the docker group
        if id -nG "${main_user}" | grep -qw "docker"; then
            echo "User ${main_user} is already a member of the docker group."
        else
            # Add the main user to the docker group
            usermod -aG docker "${main_user}"
            echo "User ${main_user} added to the docker group. Please log out and log back in for the changes to take effect."
        fi
    else
        # Get the current user
        local current_user=$(whoami)

        # Check if the user is already in the docker group
        if id -nG "${current_user}" | grep -qw "docker"; then
            echo "User ${current_user} is already a member of the docker group."
        else
            # Add the user to the docker group
            sudo usermod -aG docker "${current_user}"
            echo "User ${current_user} added to the docker group. Please log out and log back in for the changes to take effect."
        fi
    fi
}

function create-desktop-shortcut() {
  # Check if at least two arguments are provided
  if [[ $# -lt 2 ]]; then
      echo "Usage: create-desktop-shortcut <target-shell-script> <shortcut-name> [icon-path]"
      return 1
  fi

  # get main user
  main_user=$(logname || echo $SUDO_USER || echo $USER)

  # check if desktop directory exists for main user
  desktop_dir="/home/$main_user/Desktop"
  if [ ! -d "$desktop_dir" ]; then
    echo "Desktop directory not found for user $main_user"
    return 1
  fi

  # check if script file exists
  if [ ! -f "$1" ]; then
    echo "Script file not found: $1"
    return 1
  fi

  # set shortcut name
  shortcut_name=${2:-$(basename "$1" ".sh")}

  # set terminal emulator command
  terminal_emulator="gnome-terminal -- bash -c"

  # set icon path if provided and file exists
  icon_path=""
  if [[ -n "$3" ]] && [[ -f "$3" ]]; then
    icon_path="Icon=$3"
  fi

  # create shortcut file
  cat > "$desktop_dir/$shortcut_name.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=$shortcut_name
Exec=$terminal_emulator '$1; exec bash'
Terminal=true
$icon_path
EOF

  # make shortcut executable
  chmod +x "$desktop_dir/$shortcut_name.desktop"

  echo "Desktop shortcut created: $desktop_dir/$shortcut_name.desktop"
}

# Helper script function template
function script_launch_template() {
    cat <<-'EOF'
    script_launch() {
        local script_name=$1
        local script_path="${helper_scripts_path}/${script_name}"
        
        if [[ -x ${script_path} ]]; then
            ${script_path}
        else
            echo "Error: ${script_path} not found or not executable."
            exit 1
        fi
    }
EOF
}

function menu_script_template() {
    cat <<-'EOF' | sed "s|@@CUSTOM_PATH@@|$CUSTOM_PATH|g"
#!/bin/bash
CUSTOM_PATH="@@CUSTOM_PATH@@"
VERSION="1.5"
script_launch() {
    echo "Launching script: ${CUSTOM_PATH}/helper/$1"
    ${CUSTOM_PATH}/helper/$1
}

main_menu() {
    while true; do
        main_opt=$(dialog --stdout --title "Main Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                          "Logviewer" "Start different Logviewer" \
                          "Clients Menu" "Execution, Beacon and Validator Clients" \
                          "Info and KeyManagment" "Tools for Key Management and Node/Validator Information" \
                          "System" "Update, Reboot, shutdown, Backup & Restore" \
                          "-" ""\
                          "exit" "Exit the program")

        case $? in
          0)
            case $main_opt in
                "Logviewer")
                    logviewer_submenu
                    ;;
                "Clients Menu")
                    client_actions_submenu
                    ;;
                "Info and KeyManagment")
                    validator_setup_submenu
                    ;;
                "System")
                    system_submenu
                    ;;
                "-")
                    ;;
                "exit")
                    clear
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

logviewer_submenu() {
    while true; do
        lv_opt=$(dialog --stdout --title "Logviewer Menu $VERSION" --stdout --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Tabbed-Terminal Logs" "Multiple Tabs" \
                        "Tmux-Style Logs" "Single Window" \
                        "-" ""\
                        "back" "Back to main menu")

        case $? in
          0)
            case $lv_opt in
                "Tabbed-Terminal Logs")
                    clear && script_launch "log_viewer.sh"
                    ;;
                "Tmux-Style Logs")
                    clear && script_launch "tmux_logviewer.sh"
                    ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

client_actions_submenu() {
    while true; do
        ca_opt=$(dialog --stdout --title "Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Execution-Client Menu" ""\
                        "Beacon-Client Menu" ""\
                        "Validator-Client Menu" ""\
                        "-" ""\
                        "Start all Clients" ""\
                        "Stop all Clients" ""\
                        "Restart all Clients" ""\
                        "Update all Clients" ""\
                        "-" ""\
                        "back" "Back to main menu")

        case $? in
          0)
            case $ca_opt in
                "Execution-Client Menu")
                    execution_submenu
                    ;;
                "Beacon-Client Menu")
                    beacon_submenu
                    ;;
                "Validator-Client Menu")
                    validator_submenu
                    ;;
                "-")
                    ;;
                "Start all Clients")
                    clear
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Stop all Clients")
                    clear && script_launch "stop_docker.sh"
                    ;;
                "Restart all Clients")
                    clear && script_launch "stop_docker.sh"
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Update all Clients")
                    clear && script_launch "update_docker.sh"
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

execution_submenu() {
    while true; do
        exe_opt=$(dialog --stdout --title "Execution-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Execution-Client" "" \
                        "Stop Execution-Client" "" \
                        "Restart Execution-Client" "" \
                        "-" ""\
                        "Edit Execution-Client Config" "" \
                        "Show Logs" "" \
                        "Update Execution-Client" "" \
                        "-" ""\
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $exe_opt in
                "Start Execution-Client")
                    clear && ${CUSTOM_PATH}/start_execution.sh
                    ;;
                "Stop Execution-Client")
                    clear && sudo docker stop -t 300 execution
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Execution-Client")
                    clear && sudo docker stop -t 300 execution
                    sleep 1
                    sudo docker container prune -f
                    clear && ${CUSTOM_PATH}/start_execution.sh
                    ;;
                 "Edit Execution-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_execution.sh"
                    ;;
                 "Show Logs")
                    clear && sudo docker logs -f execution
                    ;;
                 "Update Execution-Client")
                   clear && docker stop -t 300 execution
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/go-pulse > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/go-erigon > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_execution.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

beacon_submenu() {
    while true; do
        bcn_opt=$(dialog --stdout --title "Beacon-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Beacon-Client" "" \
                        "Stop Beacon-Client" "" \
                        "Restart Beacon-Client" "" \
                        "-" ""\
                        "Edit Beacon-Client Config" "" \
                        "Show Logs" "" \
                        "Update Beacon-Client" "" \
                        "-" ""\
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $bcn_opt in
                "Start Beacon-Client")
                    clear && ${CUSTOM_PATH}/start_consensus.sh
                    ;;
                "Stop Beacon-Client")
                    clear && sudo docker stop -t 180 beacon 
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Beacon-Client")
                    clear && sudo docker stop -t 180 beacon
                    sleep 1
                    sudo docker container prune -f
                    ${CUSTOM_PATH}/start_consensus.sh
                    ;;
                 "Edit Beacon-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_consensus.sh"
                    ;;
                 "Show Logs")
                    clear && sudo docker logs -f beacon
                    ;;
                 "Update Beacon-Client")
                   clear && docker stop -t 180 beacon
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_consensus.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

validator_submenu() {
    while true; do
        val_opt=$(dialog --stdout --title "Validator-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Validator-Client" "" \
                        "Stop Validator-Client" "" \
                        "Restart Validator-Client" "" \
                        "-" ""\
                        "Edit Validator-Client Config" "" \
                        "Show Logs" ""\
                        "Update Validator-Client" "" \
                        "-" "" \
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $val_opt in
                "Start Validator-Client")
                    clear && ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Stop Validator-Client")${CUSTOM_PATH}/
                    clear && sudo docker stop -t 180 validator
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Validator-Client")
                    clear && sudo docker stop -t 180 validator
                    sleep 1
                    sudo docker container prune -f
                    clear && ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Edit Validator-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_validator.sh"
                    ;;
                "Show Logs")
                    clear && sudo docker logs -f validator
                    ;;
                "Update Validator-Client")
                   clear && docker stop -t 180 validator
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/validator > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_validator.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}


validator_setup_submenu() {
    while true; do
        options=("Key Management" "Generate, Add, Import or Restore Validator-Keys" \
                 "-" "" \
                 "Convert BLS-Keys" "00-BLS to 01-Execution Wallet conversion" \
                 "Exit your Validator(s)" "Initiate the Exit of your Validator(s)" \
                 "-" "" \
                 "Client Info" "Prints currently used client version" \
                 "-" "" \
                 "GoPLS - BlockMonitor" "Compare local Block# with scan.puslechain.com" \
                 "GoPLS - Database Prunning" "Prune your local DB to freeup space" \
                 "-" "" \
                 "Prysm - List Accounts" "List all Accounts from the Validator DB" \
                 "Prysm - Delete Validator" "Delete/Remove Accounts from Validator" \
                 "Prysm - Add p2p-host-ip" "Fix for v.2.2.4" \
                 "Prysm - Temp. fix CPU-Bug" "Temporarly revert back to v2.2.2" \
                 "-" "" \
                 "Validator Info per indice" "Backup, should beacon.pulsechain.com be down"\
                 "Check for Sync Committee" "Checks if local Valis are in the Sync Committee"\
                 "-" ""
                 "ReRun Initial Setup" "" \
                 "-" ""\
                 "back" "Back to main menu; Return to the main menu.")
        vs_opt=$(dialog --stdout --title "Info and KeyManagment $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 "${options[@]}")
        case $? in
            0)
                case $vs_opt in
                    "Key Management")
                        clear && script_launch "key_mgmt.sh"
                        ;;
                    "-")
                        ;;
                    "Convert BLS-Keys")
                        clear && script_launch "bls_to_execution.sh"
                        ;;
                    "Exit your Validator(s)")
                        clear && script_launch "exit_validator.sh"
                        ;;
                    "-")
                        ;;
                    "Client Info")
                       clear && script_launch "show_version.sh"
                       ;;
                    "-")
                       ;;
                    "GoPLS - BlockMonitor")
                        clear && script_launch "compare_blocks.sh"
                        ;;
                    "GoPLS - Database Prunning")
                        tmux new-session -s prune $CUSTOM_PATH/helper/gopls_prune.sh
                        ;;
                    "-")
                        ;;                        
                    "Prysm - List Accounts")
                        clear && script_launch "prysm_read_accounts.sh"
                        ;;
                    "Prysm - Delete Validator")
                        clear && script_launch "prysm_delete_validator.sh"
                        ;;
                    "Prysm - Add p2p-host-ip")
                        clear && script_launch "prysm_fix_host_ip.sh"
                        ;;                    
                    "Prysm - Temp. fix CPU-Bug")
                       clear && script_launch "prysm_fix.sh"
                       ;;
                    "-")
                        ;;
                    "Validator Info per indice")
                        clear && script_launch "status_batch.sh"
                        ;;
                    "Check for Sync Committee")
                       clear && script_launch "check_sync.sh"
                       ;;
                    "-")
                        ;;                    
                    "ReRun Initial Setup")
                        clear && script_launch "setup_validator.sh"
                        ;;
                    "back")
                        break
                        ;;
                esac
                ;;
            1)
                break
                ;;
        esac
    done
}


system_submenu() {
    while true; do
        sys_opt=$(dialog --stdout --title "System Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Update Local Helper-Files" "Get latest additions/changes for plsmenu" \
                        "Add Graceful-Shutdown to System" "for system shutdown/reboot" \
                        "-" "" \
                        "Update & Reboot System" "" \
                        "Reboot System" "" \
                        "Shutdown System" "" \
                        "-" "" \
                        "Backup and Restore" "Chaindata for go-pulse" \
                        "-" "" \
                        "back" "Back to main menu")

        case $? in
          0)
            case $sys_opt in
                "Update Local Helper-Files")
                    clear && script_launch "update_files.sh"
                    ;;
                "Add Graceful-Shutdown to System")
                    clear && script_launch "grace.sh"
                    ;;                    
                "-")
                    ;;                    
                "Update & Reboot System")
                    clear
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"
                    sleep 3
                    clear
                    echo "Getting System updates..."
                    sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y
                    read -p "Update done, reboot now? Press enter to continue or Ctrl+C to cancel."
                    sleep 5
                    sudo reboot now
                    ;;
                "Reboot System")
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"  
                    sleep 3
                    read -p "Reboot now? Press enter to continue or Ctrl+C to cancel."
                    sudo reboot now
                    ;;
                "Shutdown System")
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"  
                    sleep 3
                    read -p "Shutdown now? Press enter to continue or Ctrl+C to cancel."                    
                    sudo shutdown now
                    ;;

                "-")
                    ;;
                "Backup and Restore")
                    if tmux has-session -t bandr 2>/dev/null; then
                    # If the session exists, attach to it
                    tmux attach-session -t bandr
                    else
                    # If the session does not exist, create and attach to it
                    tmux new-session -d -s bandr $CUSTOM_PATH/helper/backup_restore.sh
                    tmux attach-session -t bandr
                    fi
                    ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

main_menu
EOF
}


# Generate the menu script for usage with the upper functions
#menu_script="$(script_launch_template)"
#menu_script+="$(printf '\nhelper_scripts_path="%s/helper"\n' "${CUSTOM_PATH}")"
#menu_script+="$(menu_script_template)"

# Write the menu script to the helper directory
#echo "${menu_script}" > "${CUSTOM_PATH}/menu.sh"
#chmod +x "${CUSTOM_PATH}/menu.sh"

#echo "Menu script has been generated and written to ${CUSTOM_PATH}/menu.sh"

#Function to get the IP-Adress Range from the local, private network

function get_local_ip() {
  local_ip=$(hostname -I | awk '{print $1}')
  echo $local_ip
}

function get_ip_range() {
  local_ip=$(get_local_ip)
  ip_parts=(${local_ip//./ })
  ip_range="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.0/24"
  echo $ip_range
}

function exit_validator_LH() {
    # Get the keystore file path from the user with tab-autocomplete
    echo "Please enter the full path to your keystore file, including the filename and extension:"
    echo ""
    echo "Note: Your local installation folder is always mounted as /blockchain within the Docker container."
    echo "This means that if your local installation folder is /home/username/blockchain, it will be mounted as /blockchain without /home/username."
    echo "Therefore, when entering the path to your keystore file, please only include the /blockchain prefix, such as /blockchain/validator_keys/keys_###.json."
    echo ""
    read -e -p "Enter path now: " keystore_path
    #echo "${keystore_path}"
    echo ""
    # Run the Docker command with the provided keystore path and the network variable
    sudo -u lighthouse docker exec -it validator lighthouse \
    --network "${LIGHTHOUSE_NETWORK_FLAG}" \
    account validator exit \
    --keystore="${keystore_path}" \
    --beacon-node http://127.0.0.1:5052 \
    --datadir "${INSTALL_PATH}"
}


function exit_validator_PR(){
    #read -e -p "Enter the path to your wallet dir now (default /blockchain): " wallet_path
    #wallet_path=${wallet_path:-/blockchain}
    sudo -u prysm docker run -it --network="host" --name="exit_validator" \
    -v "${INSTALL_PATH}/wallet/":/wallet \
    registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest \
    validator exit \
    --wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt \
    --beacon-rpc-provider=127.0.0.1:4000 
    #echo "Executing: $cmd"
    #eval "$cmd"
}



function set_directory_permissions() {
  local user1=$1
  local user2=$2
  local directory=$3
  local group=$4
  local permissions=$5

  # Check if the user1 exists
  user1_id=$(id -u $user1 2>/dev/null)
  user1_exists=$?

  # Check if the user2 exists
  user2_id=$(id -u $user2 2>/dev/null)
  user2_exists=$?

  # Determine which user is being used and set the owner
  if [ $user1_exists -eq 0 ]; then
    owner=$user1
  elif [ $user2_exists -eq 0 ]; then
    owner=$user2
  else
    echo "Neither '$user1' nor '$user2' users found."
    return 1
  fi

  echo "Using the user: $owner"

  # Set the ownership and permissions for the specified directory
  chown -R $owner:$group $directory
  chmod -R $permissions $directory
}
#set_directory_permissions "geth" "erigon" "execution" "docker" "750

function get_main_user() {
  main_user=$(logname || echo $SUDO_USER || echo $USER)
  echo "Main user: $main_user"
}

function reboot_prompt() {
    zenity --question \
           --title="Reboot Required" \
           --text="A reboot is required in order for the Setup to function properly. Do you want to restart now?" \
           --ok-label="Restart Now" \
           --cancel-label="Cancel"

    if [ $? -eq 0 ]; then
        # User clicked "Restart Now"
        sudo reboot
    else
        # User clicked "Cancel" or closed the dialog
        echo "Reboot later"
    fi
}

grace() {
    echo "Adding systemwide graceful stop for our docker containers, as well as auto-restarts of the start-scripts via cron"
    # Create a systemd service unit file
    cat << EOF | sudo tee /etc/systemd/system/graceful_stop.service
[Unit]
Description=Gracefully stop docker containers on shutdown

[Service]
ExecStart=/bin/true
ExecStop=$INSTALL_PATH/helper/stop_docker.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd manager configuration
    sudo systemctl daemon-reload

    # Enable the new service to be started on bootup
    sudo systemctl enable graceful_stop.service
    sudo systemctl start graceful_stop.service
    echo ""
    echo "Set up and enabled graceful_stop service."
    echo ""
    read -p "Press Enter to continue"
}

beacon() {
    echo "Adding beacon startup as system service"
    # Create the systemd service file
cat <<EOF | sudo tee /etc/systemd/system/beacon.service > /dev/null
[Unit]
Description=Consensus Client Startup Script
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=$INSTALL_PATH/start_consensus.sh

[Install]
WantedBy=multi-user.target
EOF
    
    # Reload systemd manager configuration
    sudo systemctl daemon-reload

    # Enable the new service to be started on bootup
    sudo systemctl enable beacon.service
    sudo systemctl start beacon.service
    echo ""
    echo "Set up and enabled beacon service."
    echo ""
    read -p "Press Enter to continue"
}

cron() {

    INSTALL_PATH=$CUSTOM_PATH
    INSTALL_PATH=${INSTALL_PATH%/}

    # Define script paths
    SCRIPTS=("$INSTALL_PATH/start_consensus.sh" "$INSTALL_PATH/start_execution.sh" "$INSTALL_PATH/start_validator.sh")

    # Iterate over scripts and add them to crontab if they exist and are executable
    for script in "${SCRIPTS[@]}"
    do
        if [[ -x "$script" ]]
        then
            # Check if the script is already in the cron list
            if ! sudo crontab -l 2>/dev/null | grep -q "$script"; then
                # If it is not in the list, add script to root's crontab
                (sudo crontab -l 2>/dev/null; echo "@reboot $script > /dev/null 2>&1") | sudo crontab -
                echo "Added $script to root's cron jobs."
            else
                echo "Skipping $script - already in root's cron jobs."
            fi
        else
            echo "Skipping $script - does not exist or is not executable."
        fi
    done
}

cron2() {

    INSTALL_PATH=${INSTALL_PATH%/}

    # Define script paths
    SCRIPTS=("$INSTALL_PATH/start_consensus.sh" "$INSTALL_PATH/start_execution.sh" "$INSTALL_PATH/start_validator.sh")

    # Iterate over scripts and add them to crontab if they exist and are executable
    for script in "${SCRIPTS[@]}"
    do
        if [[ -x "$script" ]]
        then
            # Check if the script is already in the cron list
            if ! sudo crontab -l 2>/dev/null | grep -q "$script"; then
                # If it is not in the list, add script to root's crontab
                (sudo crontab -l 2>/dev/null; echo "@reboot $script > /dev/null 2>&1") | sudo crontab -
                echo "Added $script to root's cron jobs."
            else
                echo "Skipping $script - already in root's cron jobs."
            fi
        else
            echo "Skipping $script - does not exist or is not executable."
        fi
    done
}
