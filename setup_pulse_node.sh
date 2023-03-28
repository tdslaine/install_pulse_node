#!/bin/bash


#Icosa, Hex, Hedron,
#Three shapes in symmetry dance,
#Nature's art is shown.

# v. 0.1
# By tdslaine aka Peter L Dipslayer 
#

echo -e "\033[1;33m"
echo "┌─────────────────────────────────────────────────────────┐"
echo "│   Please read the following carefully                   │"
echo "├─────────────────────────────────────────────────────────┤"
echo "│                                                         │"
echo "│                                                         │"
echo "│ This script automates the installation and setup process│"
echo "│ for pls-test-v3 NODE. By using this script, you         │"
echo "│ acknowledge that you understand the potential risks     │"
echo "│ involved and accept full responsibility for the         │"
echo "│ security and custody of your own assets.                │"
echo "│                                                         │"
echo "│ It is strongly recommended that you review the script   │"
echo "│ and understand its workings before proceeding.          │"
echo "|                                                         |"
echo "│ Currently its only a NODE, not a Validator setup        │"
echo "└─────────────────────────────────────────────────────────┘"
echo -e "\033[0m"


read -p "Do you wish to continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborting."
  exit 1
fi

echo "Choose your Execution client:"
echo "1) Geth"
echo "2) Erigon"
read -p "Enter the number (1 or 2): " ETH_CLIENT_CHOICE

case $ETH_CLIENT_CHOICE in
  1) ETH_CLIENT="geth" ;;
  2) ETH_CLIENT="erigon" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

echo "Choose your Consensus client:"
echo "1) Prysm"
echo "2) Lighthouse"
read -p "Enter the number (1 or 2): " CONSENSUS_CLIENT_CHOICE

case $CONSENSUS_CLIENT_CHOICE in
  1) CONSENSUS_CLIENT="prysm" ;;
  2) CONSENSUS_CLIENT="lighthouse" ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

# Enable tab autocompletion for the read command
if [ -n "$BASH_VERSION" ]; then
  bind '"\t":menu-complete'
fi

# Get custom path for the blockchain folder
read -e -p $'\nThe following setup will be installed under the custom path you specified.\nIt includes the creation of an execution and a consensus folder, where the databases, the keystore, and the different startup scripts will be located.\nAdditionally, the jwt-secret file will be created in this path.\n \n Setup the installation path (default: /blockchain): '  CUSTOM_PATH

# Set the default value for custom path if the user enters nothing
if [ -z "$CUSTOM_PATH" ]; then
  CUSTOM_PATH="/blockchain"
fi

# Checkpoint sync url
CHECKPOINT="https://checkpoint.v3.testnet.pulsechain.com"

# Working BootNode, temp fix for low peerCount on the consensus client - kudos to @SIN3R6Y for sharing this BootNode
BOOTNODE="enr:-L64QNIt1R1_ou9Aw5ci8gLAsV1TrK2MtWiPNGy21YsTW0HpA86hGowakgk3IVEZNjBOTVdqtXObXyErbEfxEi8Y8Z-CARSHYXR0bmV0c4j__________4RldGgykFuckgYAAAlE__________-CaWSCdjSCaXCEA--2T4lzZWNwMjU2azGhArzEiK-HUz_pnQBn_F8g7sCRKLU4GUocVeq_TX6UlFXIiHN5bmNuZXRzD4N0Y3CCIyiDdWRwgiMo"

# Docker run commands for Ethereum clients
GETH_CMD="sudo -u geth docker run -t \\
--network=host \\
-v ${CUSTOM_PATH}/blockchain \\
registry.gitlab.com/pulsechaincom/go-pulse \\
--pulsechain-testnet-v3 \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/geth \\
--http \\
--http.api eth,net,engine,admin "

ERIGON_CMD="sudo -u erigon docker run \\
--network=host \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/erigon-pulse \\
--chain=pulsechain-testnet-v3 \\
--authrpc.jwtsecret=/blockchain/jwt.hex \\
--datadir=/blockchain/execution/erigon \\
--externalcl "

# Docker run commands for Consensus clients
PRYSM_CMD="sudo -u prysm docker run -t \\
--network=host \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain \\
--pulsechain-testnet-v3 \\
--jwt-secret=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/prysm \\
--checkpoint-sync-url=${CHECKPOINT} \\
--bootstrap-node=${BOOTNODE} \\
--genesis-beacon-api-url=${CHECKPOINT} "

LIGHTHOUSE_CMD="sudo -u lighthouse docker run -t \\
--network=host \\
-v ${CUSTOM_PATH}:/blockchain \\
registry.gitlab.com/pulsechaincom/lighthouse-pulse \\
lighthouse bn \\
--network=pulsechain_testnet_v3 \\
--execution-jwt=/blockchain/jwt.hex \\
--datadir=/blockchain/consensus/lighthouse \\
--execution-endpoint=http://localhost:8551 \\
--checkpoint-sync-url=${CHECKPOINT} \\
--boot-nodes=${BOOTNODE} \\
--http "

# Use the variables in both single and separate script modes

echo "Installing PulseChain v3"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt install docker openssl tmux ufw -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir "${CUSTOM_PATH}"
sudo sh -c "openssl rand -hex 32 | tr -d '\n' > ${CUSTOM_PATH}/jwt.hex"

echo "Creating directories"
sudo mkdir -p "${CUSTOM_PATH}/execution/$ETH_CLIENT"
sudo mkdir -p "${CUSTOM_PATH}/consensus/$CONSENSUS_CLIENT"

echo "Creating users and setting permissions"
sudo useradd -M -G docker $ETH_CLIENT
sudo useradd -M -G docker $CONSENSUS_CLIENT
sudo chown -R ${ETH_CLIENT}: "${CUSTOM_PATH}/execution/$ETH_CLIENT"
sudo chown -R ${CONSENSUS_CLIENT}: "${CUSTOM_PATH}/consensus/$CONSENSUS_CLIENT"

echo "Setting up firewall including port 8545 for internal connection to the RPC"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp 
sudo ufw enable

# Allow inbound traffic for specific ports based on user choices 
if [ "$ETH_CLIENT_CHOICE" = "1" ]; then
  sudo ufw allow 30303/tcp
  sudo ufw allow 30303/udp
  
elif [ "$ETH_CLIENT_CHOICE" = "2" ]; then
  sudo ufw allow 30303/tcp
  sudo ufw allow 30303/udp
  sudo ufw allow 30304/tcp
  sudo ufw allow 30304/udp
  sudo ufw allow 42069/tcp
  sudo ufw allow 42069/udp
  sudo ufw allow 4000/udp
  sudo ufw allow 4001/tcp
fi


if [ "$CONSENSUS_CLIENT" = "prysm" ]; then
  sudo ufw allow 13000/tcp
  sudo ufw allow 12000/udp
elif [ "$CONSENSUS_CLIENT" = "lighthouse" ]; then
  sudo ufw allow 9000
fi

echo "Choose whether you want to start the Ethereum and Consensus clients separately or together:"
echo "1) Start both clients together with a single script via tmux (start_pulsechain.sh)"
echo "2) Start clients separately with two scripts (start_execution.sh and start_consensus.sh)"
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

  echo "start_pulsechain.sh script generated successfully! Start with ./start_pulsechain.sh. Everything can be found in ${CUSTOM_PATH}. Options/Flags etc... can be changed inside the script."
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


  chmod +x start_consensus.sh
  sudo mv start_consensus.sh "$CUSTOM_PATH"

  echo "start_execution.sh and start_consensus.sh scripts generated successfully! Start with ./start_execution.sh and ./start_consensus.sh. Everything can be found in ${CUSTOM_PATH}. Options/Flags can be changed inside the corresponding .sh script(s)"

fi
echo "you can now "cd "$CUSTOM_PATH"" into your folder and start the script(s)"
