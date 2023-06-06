#!/bin/bash

# Define the GitHub repository URL
REPO_URL="https://github.com/tdslaine/install_pulse_node.git"

# Define a temporary directory to clone the repository
TMP_DIR=$(mktemp -d -t ci-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXXXXX)

# Clone the repository to the temporary directory
git clone $REPO_URL $TMP_DIR

# Prompt the user for the install location with a default value
read -e -p "Please enter the path to your install location (default is /blockchain): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain}

# Verify the directory exists or create it
if [ ! -d "$INSTALL_PATH" ]; then
    echo "Directory $INSTALL_PATH does not exist"
    exit 1
fi

# Get the current username and store it in the variable main_user
main_user=$(whoami)

# Replace the value of CUSTOM_PATH with the actual INSTALL_PATH in menu.sh
sed -i "/^CUSTOM_PATH=/c\CUSTOM_PATH=\"$INSTALL_PATH\"" $TMP_DIR/helper/menu.sh
sed -i "/^helper_scripts_path=/c\helper_scripts_path=\"$INSTALL_PATH/helper\"" $TMP_DIR/helper/menu.sh


cp $TMP_DIR/setup_validator.sh $INSTALL_PATH/helper
cp $TMP_DIR/setup_monitoring.sh $INSTALL_PATH/helper
cp $TMP_DIR/helper/* $INSTALL_PATH/helper/
mv $INSTALL_PATH/helper/menu.sh $INSTALL_PATH

chmod +x $INSTALL_PATH/helper/*.sh
chmod +x $INSTALL_PATH/menu.sh

chown $main_user $INSTALL_PATH/helper/*.sh
chown $main_user $INSTALL_PATH/menu.sh

# Create a symbolic link of the menu.sh file in /usr/local/bin and name it plsmenu
sudo rm /usr/local/bin/plsmenu
sudo ln -sf $INSTALL_PATH/menu.sh /usr/local/bin/plsmenu

# Remove the temporary directory
rm -rf $TMP_DIR

echo "Update completed successfully."
echo "Press Enter to quit"
read -p ""
exec /usr/local/bin/plsmenu
