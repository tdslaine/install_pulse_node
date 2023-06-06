#!/bin/bash 

# Define your beacon node address 
BEACON_NODE=http://localhost

# Prompt the user for the install location with a default value
read -e -p "Please enter the path to your install location (default is /blockchain): " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-/blockchain}

# Let the user know about the default value
echo "The installation path is set to $INSTALL_PATH"

# Define the path to your file
INDICES_FILE="$INSTALL_PATH/valis.txt"

# Check if the indices file exists
if [ ! -f "$INDICES_FILE" ]; then
    read -p "$INDICES_FILE not found. This file will be used to store the indices of validators you want to check in the future. Would you like to create it now? (y/n): " create_file
    if [[ "$create_file" =~ ^[Yy]$ ]]
    then
        echo "#Add one validator-indices you want to check on per line" > $INDICES_FILE
        nano $INDICES_FILE
    fi
fi

# Ask user for hardcoded indices
read -p "Enter any validator indices to check that are not listed in valis.txt, separated by commas: " indices
HARDCODED_INDICES=(${indices//,/ })

# Ask user if they want to run the script in a loop
read -p "Do you want to run this script in a loop? (y/n): " run_in_loop
run_in_loop=${run_in_loop:-y}

# Function to process validators
function process_validators {
  # Read from external file if it exists
  if [ -f "$INDICES_FILE" ]; then
    while read -r VALIDATOR_INDEX 
    do 
      echo "Processing validator index $VALIDATOR_INDEX..." 

      # Check ports
      check_and_run_curl $VALIDATOR_INDEX

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

    # Check ports
    check_and_run_curl $VALIDATOR_INDEX

    echo "Finished processing validator index $VALIDATOR_INDEX." 

    # Sleep for 3 seconds
    sleep 3
  done
}

# Function to check ports and run curl commands
function check_and_run_curl {
  if nc -z localhost 5052; then
    # Run the POST curl command for the current validator index 
    curl -s -S -X POST "$BEACON_NODE:5052/lighthouse/ui/validator_metrics" -d "{\"indices\": [$1]}" -H "Content-Type: application/json" | jq 
    # Run the GET curl command for the current validator index 
    curl -s -S -X GET "$BEACON_NODE:5052/eth/v1/beacon/states/head/validators/$1" -H "accept: application/json" | jq
  elif nc -z localhost 3500; then
    # Run the GET curl command for the current validator index 
    curl -s -S -X GET "$BEACON_NODE:3500/eth/v1/beacon/states/head/validators/$1" -H "accept: application/json" | jq
  else
    echo "Neither port 5052 nor port 3500 is reachable!"
  fi
}

# Run once or in a loop
if [[ "$run_in_loop" =~ ^[Yy]$ ]]
then
  while true
  do
    process_validators
    echo "Finished one cycle, starting another..."
    echo "interrupt with Ctrl.C"
  done
else
  process_validators
  echo "Finished processing validators."
  read -p "Press any key to exit"
fi
