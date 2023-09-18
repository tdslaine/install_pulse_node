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

    cd ${INSTALL_PATH}/staking-deposit-cli
    ./deposit.sh new-mnemonic \
    --mnemonic_language=english \
    --chain=${DEPOSIT_CLI_NETWORK} \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address="${withdrawal_wallet}"


    cd "${INSTALL_PATH}"
    sudo chmod -R 770 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    sudo chmod -R 770 "${INSTALL_PATH}/wallet" >/dev/null 2>&1


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
    sudo chmod -R 440 "${INSTALL_PATH}/validator_keys"
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



while true; do
    clear
    # Prompt the user to enter the path where their keystore files are located
    echo -e "Enter the path where your 'keystore*.json' files are located."
    echo -e "For example, if your files are located in '/home/user/my_keys', provide the path '/home/user/my_keys'."
    echo -e "You can use tab-autocomplete when entering the path."
    echo ""
    read -e -p "Path to your keys: " keys_path
    # Remove trailing slashes from the path
    keys_path="${keys_path%/}"

    # Check if the directory with keystore files exists
    keystore_files=$(find "$keys_path" -name "keystore*.json" 2>/dev/null | wc -l)

    if [[ $keystore_files -gt 0 ]]; then
        sudo cp $keys_path/keystore*.json $INSTALL_PATH/validator_keys/ 2>/tmp/cp_error.log

        if [ $? -ne 0 ]; then
            echo "Error copying keystore files. Reason: $(cat /tmp/cp_error.log)"
        fi

        num_keystore_files=$(find "$INSTALL_PATH/validator_keys/" -name "keystore*.json" 2>/dev/null | wc -l)
        
        if [ "$num_keystore_files" -eq 0 ]; then
            echo "No keystore files were copied to the destination. Ensure source directory contains the expected files."
        else
            echo "Keys successfully copied."
            break
        fi

    else
        echo "No keystore files found in the provided directory. Please check and try again."
    fi
done
    
        
    echo ""
    echo "Importing validator keys now"
    echo ""

    sudo chmod -R 770 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    sudo chmod -R 770 "${INSTALL_PATH}/wallet" >/dev/null 2>&1
    
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
    #sudo chmod 550 "${INSTALL_PATH}/validator_keys"
    echo "Import into existing Setup done."
    restart_tmux_logs_session
    press_enter_to_continue
    exit 0
            
}

################################################### Restore ##################################################
# Function to restore from SeedPhrase 
Restore_from_MN() {

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
