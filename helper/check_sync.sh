#!/bin/bash

# Functions
epoch_to_time(){
    expr 1683785555 + \( $1 \* 320 \)
}

time_to_epoch(){
    expr \( $1 - 1683785555 \) / 320
}

get_committee(){
    URLSTEM="${BEACON_NODE}/eth/v1/beacon/states/finalized"
    curl -X GET "${URLSTEM}/sync_committees?epoch=$1" 2> /dev/null \
    | sed -e 's/["]/''/g' | cut -d'[' -f2 | cut -d']' -f1 | tr ',' '\n'
}

search_committee(){
    FOUND_VALIDATORS=$(get_committee $2 | grep -Ex $VALIDATOR_LIST)
    if [ -n "$FOUND_VALIDATORS" ]; then
        echo "$FOUND_VALIDATORS" | awk -v c=$1 '{print "validator:", $1, "found in", c, "sync committee"}'
        echo "$FOUND_VALIDATORS" | wc -l
    else
        echo 0
    fi
}

display_epoch(){
    echo "epoch: $1 : $(date -d@$(epoch_to_time $1)) <-- $2"
}

get_prysm_indices() {
    PUBKEYS=$(docker exec validator /app/cmd/validator/validator accounts list --wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt | grep "validating public key" | awk '{print $4}')
    echo ""
    > validator_indices.txt
    for pubkey in $PUBKEYS; do
        echo "[DEBUG] Retrieved Public Key: $pubkey"
        INDEX=$(curl -s -X GET "http://localhost:3500/eth/v1/beacon/states/head/validators/$pubkey" | jq .data.index)
        echo "[DEBUG] Index for Public Key $pubkey: $INDEX"
        echo $INDEX >> validator_indices.txt
    done
    sed -i 's/"//g' validator_indices.txt
}

get_lighthouse_indices() {
    PUBKEYS=$(docker exec beacon lighthouse account validator list -d /blockchain | grep -Eo '0x[a-fA-F0-9]{96}')
    > validator_indices.txt
    for pubkey in $PUBKEYS; do
        echo "[DEBUG] Retrieved Public Key: $pubkey"
        INDEX=$(curl -s -X GET "http://localhost:5052/eth/v1/beacon/states/head/validators/$pubkey" | jq .data.index)
        echo "[DEBUG] Index for Public Key $pubkey: $INDEX"
        echo $INDEX >> validator_indices.txt
    done
    sed -i 's/"//g' validator_indices.txt
}

# Main script
echo "Please choose your client:"
echo "1. Lighthouse"
echo "2. Prysm"
read -p "Enter your choice (1/2): " choice

case $choice in
    1)
        BEACON_NODE="http://localhost:5052"
        get_lighthouse_indices
        ;;
    2)
        BEACON_NODE="http://localhost:3500"
        get_prysm_indices
        ;;
    *)
        echo "Invalid choice!"
        exit 1
        ;;
esac

# Continue with the rest of the script
CURR_EPOCH=$(time_to_epoch $(date +%s))
CURR_START_EPOCH=`expr \( $CURR_EPOCH / 256 \) \* 256`
NEXT_START_EPOCH=`expr $CURR_START_EPOCH + 256`
NEXTB1_START_EPOCH=`expr $NEXT_START_EPOCH + 256`

echo
display_epoch $CURR_START_EPOCH   "current sync committee start"
display_epoch $CURR_EPOCH         "now"
display_epoch $NEXT_START_EPOCH   "next sync committee start"
display_epoch $NEXTB1_START_EPOCH "next-but-one sync committee start"
echo

VALIDATOR_LIST=$(cat validator_indices.txt | tr '\n' '|' | sed 's/|$//')  # Remove trailing '|'

# Call the search_committee function and store the number of validators found
FOUND_IN_CURRENT=$(search_committee "current" $CURR_EPOCH)
FOUND_IN_NEXT=$(search_committee "next" $NEXT_START_EPOCH)

# Check the total number of validators found
TOTAL_FOUND=$((FOUND_IN_CURRENT + FOUND_IN_NEXT))

# If no validators were found, echo the desired message
if [ $TOTAL_FOUND -eq 0 ]; then
    echo "No sync committee duties in this or next epoch found for local validators."
else
    echo "Sync committee duties found for local validators in the current and/or next epoch."
fi

echo "Press [Enter] to exit..."
read
