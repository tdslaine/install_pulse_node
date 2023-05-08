#!/bin/bash

# v.1

#Icosa, Hex, Hedron,
#Three shapes in symmetry dance,
#Nature's art is shown.

# By tdslaine aka Peter L Dipslayer  TG: @dipslayer369  Twitter: @dipslayer


GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

start_dir=$(pwd)
script_dir=$(dirname "$0")

source "$script_dir/functions.sh"


# Checkpoint sync url
CHECKPOINT="https://checkpoint.v4.testnet.pulsechain.com"
# Execution Network FLAG
EXECUTION_NETWORK_FLAG="pulsechain-testnet-v4"
# PRYSM Network FLAG
PRYSM_NETWORK_FLAG="pulsechain-testnet-v4"
# Lighthouse Network FLAG
LIGHTHOUSE_NETWORK_FLAG="pulsechain_testnet_v4"


clear
echo "     Pulse Node/Validator/Monitoring Setup by Dipslayer"
echo "                                                                                                                                                    
                   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                          
                 ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         
                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒                       
               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                      
              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                     
             ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    
            ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                   
           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                  
         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓   ▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓                 
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓  ▓▓▓▓▓    ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓               
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓  ▓▓▓▓▓  ▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓               
                       ▓▓   ▓▓▓   ▓▓▓   ▓▓                              
        ▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓  ▓▓▓▓   ▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓               
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓▓▓  ▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓               
         ░▓▓▓▓▓▓▓▓▓▓▓▓▓▒  ▓▓▓▓▓▓  ▓▒  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                 
           ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                  
            ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                   
             ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                    
              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                     
               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                      
                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                        
                 ▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         
                   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                                                                                   
                                                                             "
echo "                                                          
       _       _            _              _             ___ 
      | |     | |          | |            | |           /   |
 _ __ | |___  | |_ ___  ___| |_ _ __   ___| |_  __   __/ /| |
| '_ \| / __| | __/ _ \/ __| __| '_ \ / _ \ __| \ \ / / /_| |
| |_) | \__ \ | ||  __/\__ \ |_| | | |  __/ |_   \ V /\___  |
| .__/|_|___/  \__\___||___/\__|_| |_|\___|\__|   \_/     |_/
| |                                                          
|_| donations: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA                        

"
echo "Please press Enter to continue..."
read -p ""
clear                                                                                                                                                                                                                          
echo -e "\033[1;33m"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│ DISCLAIMER! Please read the following carefully!        │"
echo "├─────────────────────────────────────────────────────────┤"
echo "│ This script automates the installation and setup        │"
echo "│ process for a PulseChain Node/Validator.                │"
echo "│                                                         │"
echo "│ By using this script, you acknowledge that you          |"
echo "| understand the potential risks involved and accept      │"
echo "│ full responsibility for the security and custody        │"
echo "│ of your own assets.                                     │"
echo "│                                                         │"
echo "│ It is strongly recommended that you review the script   │"
echo "│ and understand its workings before proceeding.          │"
echo "└─────────────────────────────────────────────────────────┘"
echo -e "\033[0m"

read -p "Do you wish to continue? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborting."
  exit 1
fi
clear
echo -e "\033[1;33m"
echo -e "+============================================+"
echo -e "|                ☆ Shoutouts ☆               |"
echo -e "+============================================+"
echo -e "| Sincere thanks to @rainbowtopgun for his   |"
echo -e "| invaluable feedback & steadfast support    |"
echo -e "| during the development of these scripts.   |"
echo -e "|                                            |"
echo -e "| Special thanks to raskitoma for forking    |"
echo -e "| the Yoldark_ETH_staking_dashboard. GitHub: |"
echo -e "| https://github.com/raskitoma/pulse-        |"
echo -e "| staking-dashboard                          |"
echo -e "|                                            |"
echo -e "| Gratitude to the Pulse-dev Telegram for    |"
echo -e "| their valuable info & collective wisdom.   |"
echo -e "|                                            |"
echo -e "| Big thanks to all who contributed with     |"
echo -e "| constructive feedback to improve my work!  |"
echo -e "+--------------------------------------------+"
echo -e "\033[0m"

press_enter_to_continue


#enabling ntp for timesyncronization
clear
echo ""
echo "We are going to setup the timezone first, it is important to be synced in time for the Chain to work correctly"
sleep 2
echo "enabling ntp for timesync"
sudo timedatectl set-ntp true
echo ""
echo "enabled ntp timesync"
echo ""
echo -e "${RED}Please choose your CORRECT timezone at the following screen${NC}"
echo ""
echo "Press Enter to continue..."
read -p ""
sudo dpkg-reconfigure tzdata
echo "timezone set"
sleep 1
echo ""
clear
echo "Please choose a node option:"
echo ""
echo "1) Geth (full node, faster sync time.)"
echo "   Recommended for normal usage, stores all transactions and the most recent states"
echo ""
echo "2) Erigon (archive node, longer sync time.)"
echo "   Recommended for developers and advanced users,"
echo "   stores the entire history of the Ethereum blockchain, including all historical states"
echo ""
echo ""
read -p "Enter the number (1 or 2): " ETH_CLIENT_CHOICE

case $ETH_CLIENT_CHOICE in
  1) ETH_CLIENT="geth" ;;
  2) ETH_CLIENT="erigon" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac
echo ""

echo "Choose your Consensus client:"
echo "1) Lighthouse"
echo "2) Prysm"
read -p "Enter the number (1 or 2): " CONSENSUS_CLIENT_CHOICE

case $CONSENSUS_CLIENT_CHOICE in
  1) CONSENSUS_CLIENT="lighthouse" ;;
  2) CONSENSUS_CLIENT="prysm" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Enable tab autocompletion for the read command if line editing is enabled
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
  bind '"\t":menu-complete'
fi


# Get custom path for the blockchain folder
read -e -p $'\nThe following setup will be installed under the custom path you specified.\nIt includes the creation of an execution and a consensus folder, where the databases, the keystore, and the different startup scripts will be located.\nAdditionally, the jwt-secret file will be created in this path.\n \n Setup the installation path (default: /blockchain): '  CUSTOM_PATH

# Set the default value for custom path if the user enters nothing
if [ -z "$CUSTOM_PATH" ]; then
  CUSTOM_PATH="/blockchain"
fi

# Working BootNode, temp fix for low peerCount on the consensus client - kudos to @SIN3R6Y for sharing this BootNode
# BOOTNODE="enr:-L64QNIt1R1_ou9Aw5ci8gLAsV1TrK2MtWiPNGy21YsTW0HpA86hGowakgk3IVEZNjBOTVdqtXObXyErbEfxEi8Y8Z-CARSHYXR0bmV0c4j__________4RldGgykFuckgYAAAlE__________-CaWSCdjSCaXCEA--2T4lzZWNwMjU2azGhArzEiK-HUz_pnQBn_F8g7sCRKLU4GUocVeq_TX6UlFXIiHN5bmNuZXRzD4N0Y3CCIyiDdWRwgiMo"

# Docker run commands for Ethereum clients
GETH_CMD="sudo -u geth docker run -dt --restart=always \\
--network=host \\
--name execution \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/go-pulse:latest \\
--${EXECUTION_NETWORK_FLAG} \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/geth \\
--http \\
--txlookuplimit 0 \\
--gpo.ignoreprice 1 \\
--cache 16384 \\
--metrics \\
--pprof \\
--http.api eth,net,engine,admin "

ERIGON_CMD="sudo -u erigon docker -t run --restart=always  \\
--network=host \\
--name execution \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/erigon-pulse:latest \\
--chain=${EXECUTION_NETWORK_FLAG} \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/erigon \\
--externalcl "

# Docker run commands for Consensus clients
PRYSM_CMD="sudo -u prysm docker run -dt --restart=always \\
--network=host \\
--name beacon \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest \\
--${PRYSM_NETWORK_FLAG} \\
--jwt-secret=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/prysm \\
--checkpoint-sync-url=${CHECKPOINT} \\
--min-sync-peers 1 \\
--genesis-beacon-api-url=${CHECKPOINT} "

LIGHTHOUSE_CMD="sudo -u lighthouse docker run -dt --restart=always \\
--network=host \\
--name beacon \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
lighthouse bn \\
--network=${LIGHTHOUSE_NETWORK_FLAG} \\
--execution-jwt=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/lighthouse \\
--execution-endpoint=http://localhost:8551 \\
--checkpoint-sync-url=${CHECKPOINT} \\
--staking \\
--metrics \\
--validator-monitor-auto \\
--http "

# Use the variables in both single and separate script modes
clear
# Add the deadsnakes PPA repository to install the latest Python version
echo -e "${GREEN}Adding deadsnakes PPA to get the latest Python Version${NC}"
sudo add-apt-repository ppa:deadsnakes/ppa -y
echo ""
echo -e "${GREEN}Installing Dependencies...${NC}"
sudo apt-get update -y
sudo apt-get upgrade -y
echo ""
# Perform distribution upgrade and remove unused packages
sudo apt-get dist-upgrade -y
sudo apt autoremove -y
echo ""
# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    htop \
    gnupg \
    git \
    ufw \
    tmux \
    dialog \
    rhash \
    openssl \
    wmctrl \
    lsb-release \
    dbus-x11 \
    python3.10 python3.10-venv python3.10-dev python3-pip
echo ""
# Downloading Docker
echo -e "${GREEN}Adding Docker PPA and installing Docker${NC}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo ""
sudo apt-get update -y
echo ""
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose
echo ""
clear
echo -e "${GREEN}Starting and enabling docker service${NC}"
sudo systemctl start docker
sudo systemctl enable docker

# Adding Main user to the Docker group
add_user_to_docker_group


echo -e "${GREEN}Creating ${CUSTOM_PATH} Main-Folder${NC}"
sudo mkdir "${CUSTOM_PATH}"
echo ""
echo -e "${GREEN}Generating jwt.hex secret${NC}"
sudo sh -c "openssl rand -hex 32 | tr -d '\n' > ${CUSTOM_PATH}/jwt.hex"
echo ""
echo -e "${GREEN}Creating subFolders for ${ETH_CLIENT} and ${CONSENSUS_CLIENT}${NC}"
sudo mkdir -p "${CUSTOM_PATH}/execution/$ETH_CLIENT"
sudo mkdir -p "${CUSTOM_PATH}/consensus/$CONSENSUS_CLIENT"
echo ""

get_main_user

echo -e "${GREEN}Creating the users ${ETH_CLIENT} and ${CONSENSUS_CLIENT} and setting permissions to the folders${NC}"

sudo useradd -M -G docker $ETH_CLIENT
sudo useradd -M -G docker $CONSENSUS_CLIENT

sudo chown -R ${ETH_CLIENT}:docker "${CUSTOM_PATH}/execution"
sudo chmod -R 750 "${CUSTOM_PATH}/execution"

sudo chown -R ${CONSENSUS_CLIENT}:docker "${CUSTOM_PATH}/consensus/"
sudo chmod -R 750 "${CUSTOM_PATH}/consensus"

press_enter_to_continue


echo "Creating shared group to access jwt.hex file"

# Permission Madness
# defining group for jwt.hex file
sudo groupadd pls-shared
sudo usermod -aG pls-shared ${ETH_CLIENT}
sudo usermod -aG pls-shared ${CONSENSUS_CLIENT}

# defining file permissions for jwt.hexSS
#echo "ETH_CLIENT: ${ETH_CLIENT}"
#echo "CUSTOM_PATH: ${CUSTOM_PATH}"
#echo "File path: ${CUSTOM_PATH}/jwt.hex"
#ls -l "${CUSTOM_PATH}/jwt.hex"

sleep 1
sudo chown ${ETH_CLIENT}:pls-shared ${CUSTOM_PATH}/jwt.hex
sleep 1
sudo chmod 640 ${CUSTOM_PATH}/jwt.hex
sleep 1

#ls -l "${CUSTOM_PATH}/jwt.hex"
press_enter_to_continue
#clear
echo ""

# Firewall Setup



# Prompt for the Rules to add

echo -e "${GREEN}Setting up firewall to allow access to SSH and port 8545 for localhost and private network connection to the RPC.${NC}"

ip_range=$(get_ip_range)
read -p "Do you want to allow access to the RPC and SSH from within your local network ($ip_range)? (y/n): " local_network_choice
read -p "Do you want to allow RPC (8545) access ?(y/n): " rpc_choice

if [[ $rpc_choice == "y" ]]; then
  sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp comment 'RPC Port'
  if [[ $local_network_choice == "y" ]]; then
    sudo ufw allow from $ip_range to any port 8545 proto tcp comment 'RPC Port for private IP range'
  fi
fi

read -p "Do you want to allow SSH access to this server? (y/n): " ssh_choice

if [[ $ssh_choice == "y" ]]; then
  read -p "Enter SSH port (default is 22): " ssh_port
  if [[ $ssh_port == "" ]]; then
    ssh_port=22
  fi
  sudo ufw allow $ssh_port/tcp comment 'SSH Port'
  if [[ $local_network_choice == "y" ]]; then
    sudo ufw allow from $ip_range to any port $ssh_port proto tcp comment 'SSH Port for private IP range'
  fi
fi

#############################################################################################################

echo ""
echo -e "${GREEN}Setting to default deny incomming and allow outgoing, enabling the Firewall${NC}"
echo ""
sudo ufw default deny incoming
echo ""
sudo ufw default allow outgoing
echo ""
# Allow inbound traffic for specific ports based on user choices 
if [ "$ETH_CLIENT_CHOICE" = "1" ]; then # as per https://geth.ethereum.org/docs/fundamentals/security
  sudo ufw allow 30303/tcp
  sudo ufw allow 30303/udp
  
elif [ "$ETH_CLIENT_CHOICE" = "2" ]; then #as per https://github.com/ledgerwatch/erigon
  sudo ufw allow 30303/tcp
  sudo ufw allow 30303/udp
  sudo ufw allow 30304/tcp
  sudo ufw allow 30304/udp
  sudo ufw allow 42069/tcp
  sudo ufw allow 42069/udp
  sudo ufw allow 4000/udp
  sudo ufw allow 4001/tcp
fi


if [ "$CONSENSUS_CLIENT" = "prysm" ]; then #as per https://docs.prylabs.network/docs/prysm-usage/p2p-host-ip
  sudo ufw allow 13000/tcp
  sudo ufw allow 12000/udp
elif [ "$CONSENSUS_CLIENT" = "lighthouse" ]; then #as per https://lighthouse-book.sigmaprime.io/faq.html
  sudo ufw allow 9000
fi

echo ""
echo "enabling firewall now..."
sudo ufw enable
sleep 1
clear
echo ""
echo "The Ethereum and Consensus clients will be started separately using two different scripts."
echo "The start_execution.sh script will start the execution client."
echo "The start_consensus.sh script will start the consensus (beacon) client."
echo "The scripts will be generated in the directory \"$CUSTOM_PATH\"."
echo ""
echo "Generating scripts..."

echo ""
echo -e "${GREEN}Generating start_execution.sh script${NC}"
cat > start_execution.sh << EOL
#!/bin/bash

echo "Starting ${ETH_CLIENT}"

EOL

if [ "$ETH_CLIENT" = "geth" ]; then
sudo docker pull registry.gitlab.com/pulsechaincom/go-pulse:latest
  cat > start_execution.sh << EOL
${GETH_CMD}

EOL

elif [ "$ETH_CLIENT" = "erigon" ]; then
sudo docker pull registry.gitlab.com/pulsechaincom/erigon-pulse:latest
  cat > start_execution.sh << EOL
${ERIGON_CMD}

EOL
fi

chmod +x start_execution.sh
sudo mv start_execution.sh "$CUSTOM_PATH"
sudo chown $main_user:docker "$CUSTOM_PATH/start_execution.sh"

echo ""
echo -e "${GREEN}Generating start_consensus.sh script${NC}"
cat > start_consensus.sh << EOL
#!/bin/bash

echo "Starting ${CONSENSUS_CLIENT}"

EOL

if [ "$CONSENSUS_CLIENT" = "prysm" ]; then
sudo docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest
sudo docker pull registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest
  cat > start_consensus.sh << EOL
${PRYSM_CMD}

EOL
elif [ "$CONSENSUS_CLIENT" = "lighthouse" ]; then
sudo docker pull registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest
  cat > start_consensus.sh << EOL
${LIGHTHOUSE_CMD}

EOL
fi

chmod +x start_consensus.sh
sudo mv start_consensus.sh "$CUSTOM_PATH"
sudo chown $main_user:docker "$CUSTOM_PATH/start_consensus.sh"

echo ""
echo -e "${GREEN}start_execution.sh and start_consensus.sh created successfully!${NC}"
echo ""
echo ""
# Create the helper directory if it doesn't exist
sudo mkdir -p "${CUSTOM_PATH}/helper"

echo ""
echo -e "${GREEN}copying over helper scripts${NC}"

sudo cp log_viewer.sh "$CUSTOM_PATH/helper"
sudo cp update_docker.sh "$CUSTOM_PATH/helper"
sudo cp stop_docker.sh "$CUSTOM_PATH/helper"
sudo cp restart_docker.sh "$CUSTOM_PATH/helper"
sudo cp tmux_logviewer.sh "$CUSTOM_PATH/helper"
sudo cp setup_validator.sh "$CUSTOM_PATH/helper"
sudo cp setup_monitoring.sh "$CUSTOM_PATH/helper"
sudo cp functions.sh "$CUSTOM_PATH/helper"
sudo cp helper/LogoVector.svg "$CUSTOM_PATH/helper"


# Permissions to folders
sudo chmod -R +x $CUSTOM_PATH/helper/
sudo chmod -R 755 $CUSTOM_PATH/helper/
sudo chown -R $main_user:docker $CUSTOM_PATH/helper


echo ""
echo -e "${GREEN}Finished copying helper scripts${NC}"
echo ""

echo ""
echo "Creating a small menu for general housekeeping"
echo ""
menu_script="$(script_launch_template)"
menu_script+="$(printf '\nhelper_scripts_path="%s/helper"\n' "${CUSTOM_PATH}")"
menu_script+="$(menu_script_template)"

# Write the menu script to the helper directory
echo "${menu_script}" | sudo tee "${CUSTOM_PATH}/menu.sh" > /dev/null 2>&1
sudo chmod +x "${CUSTOM_PATH}/menu.sh"
sudo cp "${CUSTOM_PATH}/menu.sh" /usr/local/bin/plsmenu > /dev/null 2>&1
sudo chown -R $main_user:docker $CUSTOM_PATH/menu.sh

echo "Menu script has been generated and written to ${CUSTOM_PATH}/menu.sh"

read -p "Do you want to add Desktop-Shortcuts to a menu for general logging and node/validator settings (Recommended)? [Y/n] " log_choice
echo ""
echo -e "${RED}Note: You might have to right-click > allow launching on these${NC}"
echo ""
if [[ "$log_choice" =~ ^[Yy]$ || "$log_choice" == "" ]]; then
    create-desktop-shortcut ${CUSTOM_PATH}/helper/tmux_logviewer.sh tmux_LOGS
    create-desktop-shortcut ${CUSTOM_PATH}/helper/log_viewer.sh ui_LOGS
    #create-desktop-shortcut ${CUSTOM_PATH}/helper/restart_docker.sh Restart-clients
    #create-desktop-shortcut ${CUSTOM_PATH}/helper/stop_docker.sh Stop-clients
    #create-desktop-shortcut ${CUSTOM_PATH}/helper/update_docker.sh Update-clients
    create-desktop-shortcut ${CUSTOM_PATH}/menu.sh Validator-Menu ${CUSTOM_PATH}/helper/LogoVector.svg
fi

echo "Menu generated and copied over to /usr/local/bin/plsmenu - you can open this helper menu by running plsmenu in the terminal"
echo ""
press_enter_to_continue


clear
read -p "$(echo -e ${GREEN})Would you like to setup a validator? (y/n):$(echo -e ${NC}))" VALIDATOR_CHOICE
echo ""
if [ "$VALIDATOR_CHOICE" = "y" ]; then
  echo ""
  echo "Starting setup_validator.sh script"
  echo ""
  cd ${start_dir}
  #echo "debug"
  sudo chmod +x setup_validator.sh
  sudo ./setup_validator.sh
  exit 0

else
  echo "Skipping creation of validator."
  echo "You can always create a validator later by running the ./setup_validator.sh script separately."
  echo ""
fi

read -p "Do you want to start the execution and consensus scripts now? [Y/n] " choice

# Check if the user wants to run the scripts
if [[ "$choice" =~ ^[Yy]$ || "$choice" == "" ]]; then

  # Generate the command to start the scripts
  command1="${CUSTOM_PATH}/start_execution.sh > /dev/null 2>&1 &"
  command2="${CUSTOM_PATH}/start_consensus.sh > /dev/null 2>&1 &"

  # Print the command to the terminal
  echo "Running command: $command1"
  echo "Running command: $command2"

  # Run the command
  eval $command1
  sleep 1
  eval $command2
  sleep 1
fi  

  clear
  echo ""
  echo -e "${GREEN}Congratulations, node installation/setup is now complete.${NC}"
  echo ""  
  display_credits

  sleep 1
  echo "Please press Enter to exit"
  read -p ""
  exit 0
