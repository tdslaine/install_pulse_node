#!/bin/bash 

# Define your beacon node address 
BEACON_NODE=http://localhost:5052 

# Prompt the user for the install location with a default value
read -e -p "Please enter the path to your install location (default is /blockchain): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain}
echo "Using install path: $INSTALL_PATH"

# Define the path to your file
INDICES_FILE="$INSTALL_PATH/valis.txt"

# Check if the indices file exists
if [ ! -f "$INDICES_FILE" ]; then
    read -p "$INDICES_FILE not found. Would you like to create it now? (y/n): " create_file

    if [[ "${create_file,,}" == "y" ]]; then
        touch "$INDICES_FILE"
        read -p "Would you like to edit $INDICES_FILE now? (y/n): " edit_file

        if [[ "${edit_file,,}" == "y" ]]; then
            nano "$INDICES_FILE"
        fi
    fi
fi

# Array of hardcoded validator indices
HARDCODED_INDICES=(5555)

read -p "Would you like to check other validator indices not listed in $INDICES_FILE? (y/n): " check_others

if [[ "${check_others,,}" == "y" ]]; then
    read -p "Please enter the validator indices separated by comma (e.g., 1234,5678,9012): " other_indices
    IFS=',' read -r -a additional_indices <<< "$other_indices"
    HARDCODED_INDICES=("${HARDCODED_INDICES[@]}" "${additional_indices[@]}")
fi

# Infinite loop
while true
do
  # Read from external file if it exists
  if [ -f "$INDICES_FILE" ]; then
    while read -r VALIDATOR_INDEX 
    do 
      echo "Processing validator index $VALIDATOR_INDEX..." 

      # Run the GET curl command for the current validator index 
      curl -s -X GET "$BEACON_NODE/eth/v1/beacon/states/head/validators/$VALIDATOR_INDEX" -H "accept: application/json" | jq -r '{index: .data.index, status: .data.status}'

      # Run the POST curl command for the current validator index 
      curl -X POST "$BEACON_NODE/lighthouse/ui/validator_metrics" -d "{\"indices\": [$VALIDATOR_INDEX]}" -H "Content-Type: application/json" | jq 

      echo "Finished processing validator index $VALIDATOR_INDEX." 

      # Sleep for 3 seconds
      sleep 3
    done < "$INDICES_FILE"
  else
    echo "File $INDICES_FILE not found!"
  fi

  # Process hardcoded indices
  for VALIDATOR_INDEX in "${HARDCODED_INDICES[@]}"
  do
    echo "Processing validator index $VALIDATOR_INDEX..." 

    # Run the GET curl command for the current validator index 
    curl -s -X GET "$BEACON_NODE/eth/v1/beacon/states/head/validators/$VALIDATOR_INDEX" -H "accept: application/json" | jq -r '{index: .data.index, status: .data.status}'

    # Run the POST curl command for the current validator index 
    curl -X POST "$BEACON_NODE/lighthouse/ui/validator_metrics" -d "{\"indices\": [$VALIDATOR_INDEX]}" -H "Content-Type: application/json" | jq 

    echo "Finished processing validator index $VALIDATOR_INDEX
