#!/bin/bash

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



# Create the lhvalidator user with no home directory and add it to the docker group
sudo useradd -MG docker validator

# Enable tab autocompletion for the read command
if [ -n "$BASH_VERSION" ]; then
  bind '"\t":menu-complete'
fi

# Define the custom path for the validator directory
read -e -p  "please enter the path for the validator data like keys, pw etc.. (f.e.: /blockchain/validator):" custompath

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

# Run the helper script for installation
#./deposit.sh install

# Ask the user to enter the fee-receiption address
echo "Please enter the fee-receiption address (Press Enter to use the default address, which is mine lol):"
read fee_wallet

# Use a regex pattern to validate the input wallet address
if [[ -z "${fee_wallet}" ]] || ! [[ "${fee_wallet}" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
    fee_wallet="0x998D0ed46B837fbeAEb6988A6C00b721E33224Ec"
    echo "Using default fee-receiption address: ${fee_wallet}"
else
    echo "Using provided fee-receiption address: ${fee_wallet}"
fi


# Run the deposit.sh script with the entered fee-receiption address
echo "now generating the validator keys - please follow the instructions and make sure to READ! everything"
sudo ./deposit.sh new-mnemonic --num_validators=1 --mnemonic_language=english --chain=pulsechain-testnet-v3 --folder="${custompath}"
cd "${custompath}"

echo "please upload your generated "deposit_data-xxxyyyzzzz.json" to the validator dashboard at https://launchpad.v3.testnet.pulsechain.com; the deposit page is after client installation."
#echo "now sleeping for 10"
#sleep 10

echo "importing keys using lighthouse"


## Run the Lighthouse Pulse docker container as the validator user
sudo docker run -it \
    --name validator_import \
    --network=host \
    -v ${custompath}:/blockchain \
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \
    lighthouse \
    --network=pulsechain_testnet_v3 \
    account validator import \
    --directory=/blockchain/validator_keys \
    --datadir=/blockchain

sudo docker stop -t 10 validator_import

sudo docker container prune

VALIDATOR_LH="sudo -u validator docker run -it --network=host \\
    -v ${custompath}:/blockchain \\
    registry.gitlab.com/pulsechaincom/lighthouse-pulse:latest \\
    lighthouse vc \\
    --network=pulsechain_testnet_v3 \\
    --validators-dir=/blockchain/validators \\
    --suggested-fee-recipient=${fee_wallet} \\
    --beacon-nodes=http://127.0.0.1:5052 "

# Use a heredoc to create the start_validator_lh.sh file
cat << EOF > start_validator_lh.sh
#!/bin/bash
${VALIDATOR_LH}
EOF
cd ${custompath}
sudo chmod +x start_validator_lh.sh

# Change the ownership of the custompath/validator directory to validator user and group
sudo chown -R validator:validator "${custompath}"
