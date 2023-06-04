
#!/bin/bash 

# Define your beacon node address 
BEACON_NODE=http://localhost:5052 

# Define the path to your file
INDICES_FILE=/blockchain/valis.txt

# Array of hardcoded validator indices
HARDCODED_INDICES=(6694 6695 6696)

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

    echo "Finished processing validator index $VALIDATOR_INDEX." 

    # Sleep for 3 seconds
    sleep 3
  done

  echo "Finished one cycle, starting another..."
done
