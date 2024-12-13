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
 
function get_main_user() {
  main_user=$(logname || echo $SUDO_USER || echo $USER)
  echo "Main user: $main_user"
}

clear
sudo add-apt-repository -y universe
sudo apt update
sudo apt install -y git 


# Step 2: Ensure Python 3.8 is installed
echo "Ensuring Python 3.8 is installed..."
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.8 python3.8-venv python3.8-distutils python3.8-dev

# Verify Python 3.8 installation
python3.8_version=$(python3.8 -V 2>&1)
if [[ $python3.8_version != "Python 3.8"* ]]; then
    echo -e "${RED}Error: Python 3.8 is not installed correctly.${NC}"
    exit 1
fi
echo -e "${GREEN}Python 3.8 is successfully installed.${NC}"

clear

# Prompt the user for the installation path
read -e -p "Please enter the installation path (Press Enter for default: ~/stakingcli): " INSTALL_PATH

# Check if the user has entered a path
if [ -z "$INSTALL_PATH" ]; then
    INSTALL_PATH=~/stakingcli
fi

clear

echo "Checking if staking-cli is already installed..."
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
if [ ! -d "${INSTALL_PATH}" ]; then
    echo "Cloning the staking-deposit-cli repository..."
    git clone https://gitlab.com/pulsechaincom/staking-deposit-cli.git "${INSTALL_PATH}" || {
        echo -e "${RED}Failed to clone the repository. Please check your internet connection.${NC}"
        exit 1
    }
else
    echo "Directory already exists. Skipping the cloning process."
fi

# Step 3: Set up virtual environment
echo "Setting up Python 3.8 virtual environment..."
cd "${INSTALL_PATH}" || exit
python3.8 -m venv venv
source venv/bin/activate

# Install staking-cli dependencies inside venv
echo "Installing staking-cli dependencies inside the virtual environment..."
pip install --upgrade pip setuptools > /dev/null 2>&1
pip install . > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to install staking-cli dependencies.${NC}"
    deactivate
    exit 1
fi
echo -e "${GREEN}Staking-cli dependencies installed successfully inside the virtual environment.${NC}"

# Keygen script generation
echo "Generating keygen script..."
cat > "${INSTALL_PATH}/offline_key.sh" << EOL
#!/bin/bash

INSTALL_PATH="${INSTALL_PATH}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

source "\${INSTALL_PATH}/venv/bin/activate"

generate_new_validator_key() {
    clear
    echo "Generating new validator keys..."
    while true; do
        read -e -p "Enter Withdrawal Wallet Address: " withdrawal_wallet
        if [[ "\${withdrawal_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            break
        else
            echo "Invalid address format. Please try again."
        fi
    done
    cd "\${INSTALL_PATH}"
    ./deposit.sh new-mnemonic \
        --mnemonic_language=english \
        --chain=pulsechain \
        --folder="\${INSTALL_PATH}" \
        --eth1_withdrawal_address="\${withdrawal_wallet}"
}

restore_from_mnemonic() {
    clear
    echo "Restoring keys from mnemonic..."
    while true; do
        read -e -p "Enter Withdrawal Wallet Address: " withdrawal_wallet
        if [[ "\${withdrawal_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
            break
        else
            echo "Invalid address format. Please try again."
        fi
    done
    cd "\${INSTALL_PATH}"
    ./deposit.sh existing-mnemonic \
        --chain=pulsechain \
        --folder="\${INSTALL_PATH}" \
        --eth1_withdrawal_address="\${withdrawal_wallet}"
}

echo "Choose an option:"
echo "1) Generate new validator keys"
echo "2) Restore keys from mnemonic"
echo "0) Exit"
read choice

case \$choice in
    1) generate_new_validator_key ;;
    2) restore_from_mnemonic ;;
    0) exit ;;
    *) echo "Invalid option." ;;
esac
EOL

chmod +x "${INSTALL_PATH}/offline_key.sh"
sudo ln -s "${INSTALL_PATH}/offline_key.sh" /usr/local/bin/keygen

# Desktop shortcut
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

# Deactivate virtual environment
deactivate

clear
echo -e "${GREEN}Setup complete.${NC}"
echo "Run 'keygen' or use the Desktop shortcut to start."
echo ""
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
    
