#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

clear

echo ""
echo ""
echo "+-------------------------------------------------------+"
echo "|                  DipSlayer presents:                  |"
echo "|                                                       |"
echo "|            Staking-Cli Offline Setup for              |"
echo "|              Pulsechain-Mainnet only                  |"
echo "|                                                       |"
echo "+-------------------------------------------------------+"
echo ""
echo ""
echo "Disclaimer:"
echo ""
echo "This script downloads the necessary requirements for running Staking-Cli and"
echo "facilitates the generation of validator keys. It is intended to be used on a"
echo "separate, offline device."
echo ""
echo "Please ensure the following:"
echo "- The device running this script is separate from the validator itself."
echo "- The device is airgapped and disconnected from the network during the key generation process."
echo "- Once the initial setup is complete, the device should remain offline to ensure the security"
echo "  of the generated validator keys."
echo ""
echo "Please exercise caution and follow best practices to protect the integrity and security of"
echo "your validator keys."
echo ""
echo "After the initial Setup is done you can launch the Validator-Keygen via the Desktop Icon"
echo "or via the terminal command \"keygen\" from anywhere within your terminal/cli/console"
echo "+-------------------------------------------------------+"
echo ""
echo "Press Enter to Continue"
read -p ""
 
main_user=$(whoami)

clear

echo "Checking if python3 > 3.8 is installed"
echo "Press Enter to Continue"
read -p ""

command -v python3 >/dev/null 2>&1 || { echo >&2 "Python3 is required but it's not installed. Aborting."; exit 1; }

# Find the highest python3 version installed
HIGHEST_PY3_VERSION=$(dpkg --get-selections | grep -oP 'python3\.\K[0-9]+' | sort -V | tail -n 1)

REQUIRED_PY_VERSION="3.8"

if (( $(echo "$HIGHEST_PY3_VERSION < $REQUIRED_PY_VERSION" | bc -l) ))
then
    echo "Highest Python3 version is lower than $REQUIRED_PY_VERSION"
    echo "Installing Python $REQUIRED_PY_VERSION..."
    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.8
else
    echo "Highest Python3 version is $HIGHEST_PY3_VERSION, which is sufficient"
fi

clear

echo "Checking if pip3 is installed"
echo "Press Enter to Continue"
read -p ""

# Check if pip3 is installed
command -v pip3 >/dev/null 2>&1 || { echo >&2 "Pip3 is required but it's not installed. Installing..."; sudo apt install -y python3-pip; }
clear

# Prompt the user for the installation path
read -e -p "Please enter the installation path (Press Enter for default: home/"${main_user}"/stakingcli): " INSTALL_PATH

# Check if the user has entered a path
if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=~/stakingcli
fi

echo "" 

clear

echo "Checking if stakingcli is already installed"
echo "Press Enter to Continue"
read -p ""

# Check if the directory exists
if [ -d "${INSTALL_PATH}" ]; then
    while true; do
        read -p "The staking-deposit-cli folder already exists. Do you want to delete it and clone the latest version? (y/N): " confirm_delete
        if [ "$confirm_delete" == "y" ] || [ "$confirm_delete" == "Y" ]; then
            sudo rm -rf "${INSTALL_PATH}"
            break
        elif [ "$confirm_delete" == "n" ] || [ "$confirm_delete" == "N" ] || [ -z "$confirm_delete" ]; then
            echo "Skipping the cloning process as the user chose not to delete the existing folder."
            break
        else
            echo "Invalid option. Please enter 'y' or 'n'."
        fi
    done
fi

# Clone the staking-deposit-cli repository
while true; do
    if [ -d "${INSTALL_PATH}" ]; then
        echo "Directory already exists. Skipping the cloning process."
        break
    elif git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git "${INSTALL_PATH}"; then
        echo "Cloned staking-deposit-cli repository into ${INSTALL_PATH}"
        break
    else
        echo ""
        echo "Failed to clone staking-deposit-cli repository. Please check your internet connection and try again."
        echo ""
        read -p "Press 'r' to retry, any other key to exit: " choice
        if [ "$choice" != "r" ]; then
            exit 1
        fi
    fi
done


# Give execution permission to deposit.sh and run it
clear

echo "granting Permissions to stakingcli and installing requierments"
echo "Press Enter to Continue"
read -p ""

cd ${INSTALL_PATH}
chmod +x deposit.sh
sudo ./deposit.sh install


echo "generating offline_key.sh script"

NEWKEY='generate_new_validator_key() {

    clear

    echo ""
    echo "Generating the validator keys via staking-cli"
    echo ""
    echo "Please follow the instructions and make sure to READ! and understand everything on screen"
    echo ""
    echo -e "${RED}Attention:${NC}"
    echo ""
    echo "The next steps require you to enter the wallet address that you would like to use for receiving"
    echo "validator rewards while validating and withdrawing your funds when you exit the validator pool."
    echo -e "This is the ${GREEN}Withdrawal- or Execution-Wallet (they are the same)${NC}"
    echo ""
    echo -e "Make sure ${RED}you have full access${NC} to this Wallet. ${RED}Once set, it cannot be changed${NC}"
    echo ""
    echo -e "You need to provide this Wallet-Adresss in the ${GREEN}proper format (checksum)${NC}."
    echo -e "One way to achieve this, is to copy your address from the Blockexplorer"
    echo ""

    read -p "I have read this information and understand the importance of using the right Withdrawal-Wallet Address. (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Exiting script now."
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
    ./deposit.sh new-mnemonic \
    --mnemonic_language=english \
    --chain=pulsechain \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address="${withdrawal_wallet}"

    chmod -R 777 "${INSTALL_PATH}/validator_keys" >/dev/null 2>&1
    echo ""
    echo "Press Enter to quit"
    read -p ""
}'

RESTORE_KEY='Restore_from_MN() {

    clear

    echo ""
    echo "Generating the validator keys via staking-cli"
    echo ""
    echo "Please follow the instructions and make sure to READ! and understand everything on screen"
    echo ""
    echo -e "${RED}Attention:${NC}"
    echo ""
    echo "The next steps require you to enter the wallet address that you would like to use for receiving"
    echo "validator rewards while validating and withdrawing your funds when you exit the validator pool."
    echo -e "This is the ${GREEN}Withdrawal- or Execution-Wallet (they are the same)${NC}"
    echo ""
    echo -e "Make sure ${RED}you have full access${NC} to this Wallet. ${RED}Once set, it cannot be changed${NC}"
    echo ""
    echo -e "You need to provide this Wallet-Adresss in the ${GREEN}proper format (checksum)${NC}."
    echo -e "One way to achieve this, is to copy your address from the Blockexplorer"
    echo ""

    read -p "I have read this information and understand the importance of using the right Withdrawal-Wallet Address. (y/n): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Exiting script now."
        exit 1
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

    cd "${INSTALL_PATH}"
    ./deposit.sh existing-mnemonic \
    --chain=pulsechain \
    --folder="${INSTALL_PATH}" \
    --eth1_withdrawal_address="${withdrawal_wallet}"

    chmod -R 777 "${INSTALL_PATH}/validator_keys"
    echo "Your keys can be found in "${INSTALL_PATH}/validator_keys""
    echo ""
    echo "Press Enter to quit"
    read -p ""
}'

clear

echo "Generating keygen script"
echo "Press Enter to Continue"
read -p ""


cat > offline_key.sh << EOL
#!/bin/bash

INSTALL_PATH="$INSTALL_PATH"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

${NEWKEY}

${RESTORE_KEY}

echo "-----------------------------------------"
echo "|           Validator Key Setup         |"
echo "-----------------------------------------"
echo ""

while true; do
	echo "1) Generate new validator keys. (Fresh, with a new Seed)"
	echo ""
	echo "2) Restore or Add from a Seed Phrase/Mnemonic (Using an existing Seed)"
	echo ""
	echo "0) Exit/Cancel"

    read -p $'\nChoose an option (1-3): ' choice

    if [[ \$choice == 1 ]]; then
        generate_new_validator_key
        break
    elif [[ \$choice == 2 ]]; then
        Restore_from_MN
        break
    elif [[ \$choice == 0 ]]; then
        echo "Exiting..."
        exit 0
    else
        echo "Invalid option. Please choose option (1,2 or 0)."
    fi
done
EOL


chmod +x offline_key.sh
sudo ln -s "$(pwd)/offline_key.sh" /usr/local/bin/keygen


desktop_file="${HOME}/Desktop/offline_keygen.desktop"

cat > "${desktop_file}" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=Offline Keygen
Comment=Generate validator keys offline
Exec=${INSTALL_PATH}/offline_key.sh
Icon=utilities-terminal
Terminal=true
Categories=Utility;
EOL

chmod +x "${desktop_file}"

clear

echo -e "${GREEN}Setup complete${NC}"
echo ""
echo "Please disconnect your device from the Internet now."
echo ""
echo -e "You can launch the validator key setup anytime via the command ${GREEN}keygen${NC} from the terminal, or the Desktop-Icon \"Offline Keygen\""
echo "you can find the main_script here: ${INSTALL_PATH}/offline_key.sh."
echo ""
echo "Keys will be generated in this folder: ${INSTALL_PATH}/validator_keys"
echo ""
echo "Press Enter to continue"
read -p ""
echo ""
echo "Brought to you by:"
echo "██████__██_██████__███████_██_______█████__██____██_███████_██████__"
echo "██___██_██_██___██_██______██______██___██__██__██__██______██___██_"
echo "██___██_██_██████__███████_██______███████___████___█████___██████__"
echo "██___██_██_██___________██_██______██___██____██____██______██___██_"
echo "██████__██_██______███████_███████_██___██____██____███████_██___██_"
echo -e "${GREEN}For Donations use \nERC20: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA${NC}"
echo ""
    
