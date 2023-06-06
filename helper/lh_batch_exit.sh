#!/bin/bash

echo -e "\n\n"
echo "   *********************************************************************************************************"
echo "   *                                                                                                       *"
echo "   *  WARNING: This script is designed for batch-processing multiple keystore-files, and will          *"
echo "   *  voluntarily exit the assigned validator for each keystore-file. This action is irreversible.     *"
echo "   *  Please ensure you fully understand the implications of this action before proceeding.            *"
echo "   *                                                                                                       *"
echo "   *  This is for Lighthouse validators only. It may be a good idea to copy the keystore                   *"
echo "   *  files you want to process to a different location and set accordingly in the following steps.       *"
echo "   *                                                                                                       *"
echo "   *********************************************************************************************************"
echo -e "\n\n"

read -p "Do you wish to proceed (y/n)? " answer
case ${answer:0:1} in
    y|Y )
    echo "Proceeding..."
    ;;
    * )
    echo "Aborting..."
    exit
    ;;
esac

read -e -p "Enter your installation path (default is /blockchain): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain}


echo "Enter your password file path (default is $INSTALL_PATH/keystore_pw.txt)"
read -e -p  "If none exists, it will be created, just hit enter: "  PASSWORD_FILE
echo ""
PASSWORD_FILE=${PASSWORD_FILE:-$INSTALL_PATH/keystore_pw.txt}

# Check if password file exists
if [[ ! -f "$PASSWORD_FILE" ]]; then
    echo "Password file not found. Creating one..."
    read -s -p "Enter your keystore password: " keystore_pw
    echo $keystore_pw > $PASSWORD_FILE
    chmod 600 $PASSWORD_FILE
    echo "Password file created."
fi

read -p "Enter your keystore files directory (default is $INSTALL_PATH/validator_keys): " KEYSTORE_DIR
KEYSTORE_DIR=${KEYSTORE_DIR:-$INSTALL_PATH/validator_keys}

BEACON_NODE=http://localhost:5052

# Ensure the log file is empty before we start
echo "" > $INSTALL_PATH/processed_keystores.log

for KEYSTORE_FILE in $KEYSTORE_DIR/key*.json
do
  echo "Processing $KEYSTORE_FILE..."
  sudo -u lighthouse docker exec -it validator lighthouse  \
   --network pulsechain \
   account validator exit \
    --keystore=$KEYSTORE_FILE \
    --password-file=$PASSWORD_FILE \
    --beacon-node $BEACON_NODE \
    --datadir $INSTALL_PATH

  echo "$KEYSTORE_FILE processed." | tee -a $INSTALL_PATH/processed_keystores.log
done

echo "All done! You can find the log file at $INSTALL_PATH/processed_keystores.log"
echo ""
echo "Press Enter to continue"
read -p ""
