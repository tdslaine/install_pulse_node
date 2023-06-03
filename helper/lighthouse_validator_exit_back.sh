#!/bin/bash

# Define the path to the folder containing your keystore files
KEYSTORE_DIR=/blockchain/validator_keys

# Define the path to your password file
PASSWORD_FILE=/blockchain/test.txt

# Define your installation path
INSTALL_PATH=/blockchain

# Define your beacon node address
BEACON_NODE=http://localhost:5052

# Define the username you want to run the command as
#USER=lighthouse

# Loop through each keystore file in the directory
for KEYSTORE_FILE in $KEYSTORE_DIR/key*.json
do
  echo "Processing $KEYSTORE_FILE..."

  # Run the exit command for the current keystore file
  sudo -u lighthouse docker exec -it validator lighthouse  \
   --network pulsechain \
   account validator exit \
    --keystore=$KEYSTORE_FILE \
    --password-file=$PASSWORD_FILE \
    --beacon-node $BEACON_NODE \
    --datadir $INSTALL_PATH

  echo "Finished processing $KEYSTORE_FILE."
done

echo "All done!"

