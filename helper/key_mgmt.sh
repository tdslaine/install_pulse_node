#!/bin/bash

start_dir=$(pwd)
script_dir=$(dirname "$0")
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

source "$script_dir/functions.sh"

get_main_user
tab_autocomplete
check_and_set_network_variables
get_install_path

# Set up Python 3.8 virtual environment
function setup_python_venv() {
    # Check if Python 3.8 is already installed
    if command -v python3.8 >/dev/null 2>&1; then
        echo "Python 3.8 is already installed."
    else
        echo "Python 3.8 not found. Installing Python 3.8..."
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
        sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils python3.8-dev

        # Verify Python 3.8 installation
        #python3.8_version=$(python3.8 -V 2>&1)
        #if [[ $python3.8_version != "Python 3.8"* ]]; then
        #    echo -e "${RED}Error: Python 3.8 is not installed correctly.${NC}"
        #    exit 1
        #fi
    fi

    # Create venv if it doesn't exist
    if [ ! -d "${INSTALL_PATH}/staking-deposit-cli/venv" ]; then
        echo "Creating virtual environment..."
        cd "${INSTALL_PATH}/staking-deposit-cli" || exit
        python3.8 -m venv venv
    else
        echo "Virtual environment already exists."
    fi

    # Activate venv and install dependencies
    source "${INSTALL_PATH}/staking-deposit-cli/venv/bin/activate"
    echo "Installing dependencies inside virtual environment..."
    pip install --upgrade pip setuptools > /dev/null 2>&1
    pip install -r requirements.txt > /dev/null 2>&1
    pip install . > /dev/null 2>&1
    deactivate
    echo -e "${GREEN}Python 3.8 virtual environment setup complete.${NC}"
}

# Call the function
setup_python_venv


setup_python_venv

function get_user_choices() {
    echo ""
    echo "+--------------------------------------------+"
    echo "| Choose your Validator Client               |"
    echo "|                                            |"
    echo "| (based on your consensus/beacon Client)    |"
    echo "+--------------------------------------------+"
    echo "| 1. Lighthouse                              |"
    echo "|                                            |"
    echo "| 2. Prysm                                   |"
    echo "+--------------------------------------------+"
    echo "| 0. Return or Exit                          |"
    echo "+--------------------------------------------+"

    echo ""
    read -p "Enter your choice (1, 2 or 0): " client_choice

    # Validate user input for client choice
    while [[ ! "$client_choice" =~ ^[0-2]$ ]]; do
        echo "Invalid input. Please enter a valid choice (1, 2 or 0): "
        read -p "Enter your choice (1, 2 or 0): " client_choice
    done

    if [[ "$client_choice" == "0" ]]; then
        echo "Exiting..."
        exit 0
    fi
}
get_user_choices



generate_new_validator_key() {
    source "${INSTALL_PATH}/staking-deposit-cli/venv/bin/activate"
    
    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    echo "Adding into an existing setup requires all running validator-clients to stop. This action will take place now."
    press_enter_to_continue
    stop_docker_container "validator" >/dev/null 2>&1

    warn_network
    clear

    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        network_interface_DOWN
    fi

    echo ""
    echo "Generating the validator keys via staking-cli"
    echo ""
    echo "Please follow the instructions and make sure to READ! and understand everything on screen"
    echo ""
    echo -e "${RED}Attention:${NC}"
    echo ""
    echo "The next step requires you to enter the wallet address that you would like to use for receiving"
    echo "validator rewards while validating and withdrawing your funds when you exit the validator pool."
    echo -e "This is the ${GREEN}Withdrawal- or Execution-Wallet (they are the same)${NC}"
    echo ""
    echo -e "Make sure ${RED}you have full access${NC} to this Wallet. ${RED}Once set, it cannot be changed${NC}"
    echo ""
    echo -e "You need to provide this Wallet-Adresss in the ${GREEN}proper format (checksum)${NC}."
    echo -e "One way to achive this, is to copy your adress from the Blockexplorer"
    echo ""
    if confirm_prompt "I have read this information and confirm that I understand the importance of using the right Withdrawal-Wallet Address."; then
        echo ""
        echo "proceeding..."
        sleep 2
    else
        echo "Exiting script now."
        network_interface_UP
        exit 1
    fi


    echo ""

# Check if the address is a valid address, loop until it is...
while true; do
    read -e -p "Please enter your Execution/Withdrawal-Wallet address: " withdrawal_wallet
    if [[ "${withdrawal_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        break
    else
        echo "Invalid address format. Please enter a valid PRC20 address."
    fi
done

    
    # Running staking-cli to Generate the new validator_keys
    echo ""
    echo "Starting staking-cli to Generate the new validator_keys"
    echo ""
    
    cd "${INSTALL_PATH}"
    sudo chmod -R 777 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    sudo chmod -R 777 "${INSTALL_PATH}/wallet" >/dev/null 2>&1

    
    cd ${INSTALL_PATH}/staking-deposit-cli
    ./deposit.sh new-mnemonic \
    --mnemonic_language=english \
    --chain=${DEPOSIT_CLI_NETWORK} \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address="${withdrawal_wallet}"

    deactivate

    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        network_interface_UP
    fi

    if [[ "$client_choice" == "1" ]]; then
        import_lighthouse_validator
    elif [[ "$client_choice" == "2" ]]; then
        import_prysm_validator
    fi

sudo find "$INSTALL_PATH/validator_keys" -type f -name "keystore*.json" -exec sudo chmod 440 {} \;
sudo find "$INSTALL_PATH/validator_keys" -type f -name "deposit*.json" -exec sudo chmod 444 {} \;
sudo find "$INSTALL_PATH/validator_keys" -type f -exec sudo chown $main_user:pls-validator {} \;



    start_script ../start_validator
    
    echo ""
    sudo chmod -R 777 "${INSTALL_PATH}/validator_keys"
    echo "Import into existing Setup done."
    restart_tmux_logs_session
    press_enter_to_continue
    exit 0
    
}

################################################### Import ##################################################
import_restore_validator_keys() {
    

    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    echo "Importing into an existing setup requires all running validator-clients to stop. This action will take place now."
    press_enter_to_continue
    stop_docker_container "validator" >/dev/null 2>&1



    clear
    # Prompt the user to enter the path where their keystore files are located
    echo -e "Enter the path where your 'keystore*.json' files are located."
    echo -e "For example, if your files are located in '/home/user/my_keys', provide the path '/home/user/my_keys'."
    echo -e "You can use tab-autocomplete when entering the path."
    echo ""
    read -e -p "Path to your keys: " keys_path
    # Remove trailing slashes from the path
    keys_path="${keys_path%/}"

            
    echo ""
    echo "Importing validator keys now"
    echo ""

    #sudo chmod -R 770 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    sudo chmod -R 770 "${INSTALL_PATH}/wallet" >/dev/null 2>&1
    
    if [[ "$client_choice" == "1" ]]; then
            # Base command
    cmd="sudo docker run -it \
        --name validator_import \
        --network=host \
        -v ${INSTALL_PATH}:/blockchain \
        -v ${keys_path}:/keys \
        registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
        lighthouse \
        --network=${LIGHTHOUSE_NETWORK_FLAG} \
        account validator import \
        --directory=/keys \
        --datadir=/blockchain"
    
    # Execute the Docker command or handle error
    eval $cmd || echo "Error during Lighthouse import"
    
        elif [[ "$client_choice" == "2" ]]; then
        
        sudo chmod -R 0600 "${INSTALL_PATH}/wallet/direct/accounts/all-accounts.keystore.json"
        
        docker_cmd="docker run --rm -it \
        --name validator_import \
        -v ${keys_path}:/keys \
        -v $INSTALL_PATH/wallet:/wallet \
        registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest \
        accounts import \
        --${PRYSM_NETWORK_FLAG} \
        --keys-dir=/keys \
        --wallet-dir=/wallet \
        --wallet-password-file=/wallet/pw.txt"
    
    # Execute the Docker command or handle error
    	eval $docker_cmd || echo "Error during Prysm import"
    fi

#sudo find "$INSTALL_PATH/validator_keys" -type f -name "keystore*.json" -exec sudo chmod 440 {} \;
#sudo find "$INSTALL_PATH/validator_keys" -type f -name "deposit*.json" -exec sudo chmod 444 {} \;
#sudo find "$INSTALL_PATH/validator_keys" -type f -exec sudo chown $main_user:pls-validator {} \;


     
    start_script ../start_validator
    
    echo ""
    #sudo chmod 550 "${INSTALL_PATH}/validator_keys"
    echo "Import into existing Setup done."
    restart_tmux_logs_session
    press_enter_to_continue
    exit 0
            
}

################################################### Restore ##################################################
# Function to restore from SeedPhrase 
Restore_from_MN() {
    source "${INSTALL_PATH}/staking-deposit-cli/venv/bin/activate"
    echo "Restoring validator_keys from SeedPhrase (Mnemonic)"

    if [[ "$client_choice" == "1" ]]; then
        check_and_pull_lighthouse
    elif [[ "$client_choice" == "2" ]]; then
        check_and_pull_prysm_validator
    fi

    echo "Importing into an existing setup requires all running validator-clients to stop. This action will take place now."
    press_enter_to_continue
    stop_docker_container "validator" >/dev/null 2>&1
    
    clear

    warn_network

    clear


    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        network_interface_DOWN
    fi
    # Check if the address is a valid address, loop until it is...
    while true; do
    read -e -p "Please enter your Execution/Withdrawal-Wallet address: " withdrawal_wallet
    if [[ "${withdrawal_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        break
    else
        echo "Invalid address format. Please enter a valid PRC20 address."
    fi
    done
    
    
    echo ""
    echo "Now running staking-cli command to restore from your SeedPhrase (Mnemonic)"
    echo ""
    
    cd "${INSTALL_PATH}"
    sudo chmod -R 777 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    sudo chmod -R 777 "${INSTALL_PATH}/wallet" >/dev/null 2>&1
       
    cd ${INSTALL_PATH}/staking-deposit-cli/
    ./deposit.sh existing-mnemonic \
    --chain=${DEPOSIT_CLI_NETWORK} \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address="${withdrawal_wallet}"
     
    deactivate
    
    if [[ "$network_off" =~ ^[Yy]$ ]]; then
        network_interface_UP
    fi

    if [[ "$client_choice" == "1" ]]; then
        import_lighthouse_validator
    elif [[ "$client_choice" == "2" ]]; then
        import_prysm_validator

    fi

sudo chmod -R 770 "${INSTALL_PATH}/validator_keys"
sudo find "$INSTALL_PATH/validator_keys" -type f -name "keystore*.json" -exec sudo chmod 770 {} \;
sudo find "$INSTALL_PATH/validator_keys" -type f -name "deposit*.json" -exec sudo chmod 774 {} \;
sudo find "$INSTALL_PATH/validator_keys" -type f -exec sudo chown $main_user:pls-validator {} \;


 
    start_script ../start_validator
    
    echo ""
    echo "Import into existing Setup done."
    #sudo chmod -R 770 "${INSTALL_PATH}/validator_keys"
    restart_tmux_logs_session
    press_enter_to_continue
    exit 0
}
    


# Selection menu
echo "-----------------------------------------"
echo "|           Validator Key Setup         |"
echo "-----------------------------------------"
echo ""
PS3=$'\nChoose an option (1-4): '
options=("Generate new validator_keys (fresh)" "Import/Restore validator_keys from a Folder (from Offline generation or Backup)" "Restore or Add from a Seed Phrase (Mnemonic) " "Exit/Cancel")
COLUMNS=1
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

        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose option (1-4)."
            ;;
    esac
done
