#!/bin/bash

# Define the file containing your validator indices
INDICES_FILE=/blockchain/valis.txt

# Define your beacon node address
BEACON_NODE=http://localhost:5052

# Loop through each line in the indices file
while read -r VALIDATOR_INDEX
do
  echo "Processing validator index $VALIDATOR_INDEX..."

  # Run the curl command for the current validator index
  curl -s -X GET "$BEACON_NODE/eth/v1/beacon/states/head/validators/$VALIDATOR_INDEX" -H "accept: application/json" | jq -r '{index: .data.index, status: .data.status}'

  echo "Finished processing validator index $VALIDATOR_INDEX."
done < "$INDICES_FILE"

echo "All done!"
