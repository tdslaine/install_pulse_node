#!/bin/bash


#Icosa, Hex, Hedron,
#Three shapes in symmetry dance,
#Nature's art is shown.

# v. 0.1
# By tdslaine aka Peter L Dipslayer 
#
# Set color variables
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "\033[1;33m"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│   Please read the following carefully                   │"
echo "├─────────────────────────────────────────────────────────┤"
echo "│                                                         │"
echo "│                                                         │"
echo "│ This script automates the installation and setup process│"
echo "│ for pls-test-v3 NODE plus lighthouse validator.         │"
echo "│ By using this script, you                               |"
echo "| acknowledge that you understand the potential risks     │"
echo "│ involved and accept full responsibility for the         │"
echo "│ security and custody of your own assets.                │"
echo "│                                                         │"
echo "│ It is strongly recommended that you review the script   │"
echo "│ and understand its workings before proceeding.          │"
echo "|                                                         |"
echo "│ node setup with the option to add lighthouse validator  │"
echo "└─────────────────────────────────────────────────────────┘"
echo -e "\033[0m"


read -p "Do you wish to continue? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborting."
  exit 1
fi

#enabling ntp for timesyncronization
echo ""
echo "We are going to setup the timezone first, it is important to be synced in time for the Chain to work correctly"
sleep 2
echo "enabling ntp for timesync"
sudo timedatectl set-ntp true
echo "enabled ntp timesync"
echo "please choose your ${RED}correct timezone${NC}"
sleep 2
sudo dpkg-reconfigure tzdata
echo "timezone set"
sleep 1

echo "Choose your Execution client:"
echo "1) Geth (full node, authors choice)"
echo "2) Erigon (archive)"
read -p "Enter the number (1 or 2): " ETH_CLIENT_CHOICE

case $ETH_CLIENT_CHOICE in
  1) ETH_CLIENT="geth" ;;
  2) ETH_CLIENT="erigon" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

echo "Choose your Consensus client:"
echo "1) Prysm"
echo "2) Lighthouse (authors choice)"
read -p "Enter the number (1 or 2): " CONSENSUS_CLIENT_CHOICE

case $CONSENSUS_CLIENT_CHOICE in
  1) CONSENSUS_CLIENT="prysm" ;;
  2) CONSENSUS_CLIENT="lighthouse" ;;
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

# Ask the user to enter the fee-receiption address
#echo "Please enter the fee-receiption address (it is the address that will receive the fees your validator will earn) (Press Enter to use the default address, which is mine and can be changed later in the generated .sh script):"
#read fee_wallet

# Use a regex pattern to validate the input wallet address
#if [[ -z "${fee_wallet}" ]] || ! [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
#    fee_wallet="0x998D0ed46B837fbeAEb6988A6C00b721E33224Ec"
#    echo "Using default fee-receiption address: ${fee_wallet}"
#else
#    echo "Using provided fee-receiption address: ${fee_wallet}"
#fi

# Checkpoint sync url
CHECKPOINT="https://checkpoint.v3.testnet.pulsechain.com"

# Working BootNode, temp fix for low peerCount on the consensus client - kudos to @SIN3R6Y for sharing this BootNode
BOOTNODE="enr:-L64QNIt1R1_ou9Aw5ci8gLAsV1TrK2MtWiPNGy21YsTW0HpA86hGowakgk3IVEZNjBOTVdqtXObXyErbEfxEi8Y8Z-CARSHYXR0bmV0c4j__________4RldGgykFuckgYAAAlE__________-CaWSCdjSCaXCEA--2T4lzZWNwMjU2azGhArzEiK-HUz_pnQBn_F8g7sCRKLU4GUocVeq_TX6UlFXIiHN5bmNuZXRzD4N0Y3CCIyiDdWRwgiMo"

# Docker run commands for Ethereum clients
GETH_CMD="sudo -u geth docker run -t --restart=always \\
--network=host \\
--name execution \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/go-pulse:latest \\
--pulsechain-testnet-v3 \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/geth \\
--http \\
--txlookuplimit 0 \\
--gpo.ignoreprice 1 \\
--cache 8192 \\
--http.api eth,net,engine,admin "

ERIGON_CMD="sudo -u erigon docker run --restart=always  \\
--network=host \\
--name execution \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/erigon-pulse:latest \\
--chain=pulsechain-testnet-v3 \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/erigon \\
--externalcl "

# Docker run commands for Consensus clients
PRYSM_CMD="sudo -u prysm docker run -t --restart=always \\
--network=host \\
--name beacon \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest \\
--pulsechain-testnet-v3 \\
--jwt-secret=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/prysm \\
--checkpoint-sync-url=${CHECKPOINT} \\
--bootstrap-node=${BOOTNODE} \\
--min-sync-peers 1 \\
--genesis-beacon-api-url=${CHECKPOINT} "

LIGHTHOUSE_CMD="sudo -u lighthouse docker run -t --restart=always \\
--network=host \\
--name beacon \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
lighthouse bn \\
--network=pulsechain_testnet_v3 \\
--execution-jwt=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/lighthouse \\
--execution-endpoint=http://localhost:8551 \\
--checkpoint-sync-url=${CHECKPOINT} \\
--boot-nodes=${BOOTNODE} \\
--http "

# Use the variables in both single and separate script modes

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
    gnupg \
    git \
    ufw \
    tmux \
    openssl \
    lsb-release \
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
echo -e "${GREEN}Starting and enabling docker service${NC}"
sudo systemctl start docker
sudo systemctl enable docker

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

echo -e "${GREEN}Creating the users ${ETH_CLIENT} and ${CONSENSUS_CLIENT} and setting permissions to the folders${NC}"
sudo useradd -M -G docker $ETH_CLIENT
sudo useradd -M -G docker $CONSENSUS_CLIENT
sudo chown -R ${ETH_CLIENT}: "${CUSTOM_PATH}/execution/$ETH_CLIENT"
sudo chown -R ${CONSENSUS_CLIENT}: "${CUSTOM_PATH}/consensus/$CONSENSUS_CLIENT"

echo ""
echo -e "${GREEN}Setting up firewall including port 22 and 8545 for internal connection to the RPC${NC}"
read -p "Do you want to allow RPC (8545) access from localhost? (y/n): " rpc_choice

if [[ $rpc_choice == "y" ]]; then
  sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp comment 'RPC Port'
else
  sudo ufw deny from 127.0.0.1 to any port 8545 proto tcp comment 'RPC Port'
fi

read -p "Do you want to allow SSH access to this server? (y/n): " ssh_choice
if [[ $ssh_choice == "y" ]]; then
  read -p "Enter SSH port (default is 22): " ssh_port
  if [[ $ssh_port == "" ]]; then
    ssh_port=22
  fi
  sudo ufw allow $ssh_port/tcp comment 'SSH Port'
else
  read -p "Warning: Denying SSH access to this server may disconnect your current SSH connection. Please make sure you have an alternative way to access the server before proceeding. Do you want to proceed with denying SSH access? (y/n): " ssh_confirm
  if [[ $ssh_confirm == "y" ]]; then
    sudo ufw deny 22/tcp comment 'SSH Port'
  else
    echo "SSH access not denied. Make sure to allow SSH-Access if needed"
  fi
fi
echo ""
echo -e "${GREEN}Setting to default deny incomming and allow outgoing, enabling the Firewall${NC}"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
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
echo "Choose whether you want to start the Ethereum and Consensus clients separately or together:"
echo ""
echo "1) Option 1 - ADVANCED - will start both clients at the same time using a single script, which is run inside a tmux session. THIS IS ADVANCED! and should only be used by people who know how to control tmux.( will result in a single start_pulsechain.sh script)"
echo ""
echo "2) Option 2 - EASY - involves starting the two clients separately using two different scripts - one for execution and one for consensus. (will result in two script, start_execution.sh and start_consensus.sh)"
read -p "Enter the number (1 or 2): " START_SCRIPT_CHOICE

case $START_SCRIPT_CHOICE in
  1) START_SCRIPT_MODE="single" ;;
  2) START_SCRIPT_MODE="separate" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac


if [ "$START_SCRIPT_MODE" = "single" ]; then

  echo "Generating start_pulsechain.sh script"
  cat > start_pulsechain.sh << EOL
#!/bin/bash

echo "Starting Docker containers in tmux"

tmux new-session -d -s pulsechain
tmux split-window -v

tmux select-pane -t 0
tmux send-keys "echo 'Starting ${ETH_CLIENT} client'" C-m

tmux select-pane -t 1
tmux send-keys "echo 'Starting ${CONSENSUS_CLIENT} client'" C-m

EOL

  if [ "$ETH_CLIENT" = "geth" ]; then
    cat >> start_pulsechain.sh << EOL
tmux select-pane -t 0
tmux send-keys "${GETH_CMD}" C-m

EOL

  elif [ "$ETH_CLIENT" = "erigon" ]; then
    cat >> start_pulsechain.sh << EOL
tmux select-pane -t 0
tmux send-keys "${ERIGON_CMD}" C-m

EOL
  fi


  if [ "$CONSENSUS_CLIENT" = "prysm" ]; then
    cat >> start_pulsechain.sh << EOL
tmux select-pane -t 1
tmux send-keys "${PRYSM_CMD}" C-m

EOL
  elif [ "$CONSENSUS_CLIENT" = "lighthouse" ]; then
    cat >> start_pulsechain.sh << EOL
tmux select-pane -t 1
tmux send-keys "${LIGHTHOUSE_CMD}" C-m

EOL
  fi

  cat >> start_pulsechain.sh << EOL

tmux attach-session -t pulsechain
EOL

  chmod +x start_pulsechain.sh
  sudo mv start_pulsechain.sh "$CUSTOM_PATH"

  echo "${GREEN}The start_pulsechain.sh script has been generated successfully! To start the script, run ./start_pulsechain.sh. You can find everything related to the script in the ${CUSTOM_PATH} directory. You can modify any options or flags inside the script itself using a text editor such as nano.${NC}"
fi



# If the user selects the separate script mode
if [ "$START_SCRIPT_MODE" = "separate" ]; then

  echo "Generating start_execution.sh script"
  cat > start_execution.sh << EOL
  #!/bin/bash

  echo "Starting ${ETH_CLIENT}"

EOL

if [ "$ETH_CLIENT" = "geth" ]; then
  cat >> start_execution.sh << EOL
${GETH_CMD}

EOL

  elif [ "$ETH_CLIENT" = "erigon" ]; then
    cat >> start_execution.sh << EOL
${ERIGON_CMD}

EOL
  fi

  chmod +x start_execution.sh
  sudo mv start_execution.sh "$CUSTOM_PATH"

  echo "Generating start_consensus.sh script"
  cat > start_consensus.sh << EOL
  #!/bin/bash

  echo "Starting ${CONSENSUS_CLIENT}"

EOL

  if [ "$CONSENSUS_CLIENT" = "prysm" ]; then
    cat >> start_consensus.sh << EOL
${PRYSM_CMD}

EOL
  elif [ "$CONSENSUS_CLIENT" = "lighthouse" ]; then
    cat >> start_consensus.sh << EOL
${LIGHTHOUSE_CMD}

EOL
  fi


echo "${GREEN}start_execution.sh and start_consensus.sh created successfully!${NC}"
echo ""
echo -e "${GREEN}Initial node setup complete! Begin syncing Pulse chain by starting execution and consensus clients.${NC}"
echo -e "${GREEN}Enter cd "$CUSTOM_PATH" in your terminal to access the script directory.${NC}"
echo -e "${GREEN}Run ./start_execution.sh and ./start_consensus.sh to start the clients.${NC}"

fi

echo -e "${GREEN} - Run each start script once; Docker container will auto-restart on reboot/crashes.${NC}"
echo -e "${GREEN} - Use ./log_viewer.sh to view and follow log files.${NC}"

echo ""

echo ""
echo "copying over helper scripts"
chmod +x start_consensus.sh
sudo mv start_consensus.sh "$CUSTOM_PATH"
chmod +x log_viewer.sh
sudo mv log_viewer.sh "$CUSTOM_PATH"
chmod +x watchtower.sh
sudo mv watchtower.sh "$CUSTOM_PATH"
chmod +x stop_remove_images.sh
sudo mv stop_remove_images.sh "$CUSTOM_PATH"
echo "finished copying helper scripts"
echo ""

read -p "Would you like to create a Lighthouse validator? (y/n):" VALIDATOR_CHOICE
echo ""
if [ "$VALIDATOR_CHOICE" = "y" ]; then
  echo "Running validator_test.sh script"
  chmod +x validator_test.sh
  sudo ./validator_test.sh
else
  echo "Skipping creation of validator."
  echo "You can always create a validator later by running the ./validator_test.sh script separately."
fi
