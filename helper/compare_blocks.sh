#!/bin/bash

user_agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"

while true; do
  clear

  local_block_hex=$(curl -s -X POST -H "Content-Type: application/json" -H "User-Agent: ${user_agent}" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":83}' 127.0.0.1:8545 | jq -r '.result' | sed 's/0x//')
  local_block_dec=$(printf "%d" "0x${local_block_hex}")

  external_block_hex=$(curl -s -X POST -H "Content-Type: application/json" -H "User-Agent: ${user_agent}" --data '{"id":0,"jsonrpc":"2.0","method":"eth_blockNumber","params":[]}' "https://rpc-pulsechain.g4mm4.io" | jq -r '.result' | sed 's/0x//')
  external_block_dec=$(printf "%d" "0x${external_block_hex}")

  echo "Local block: ${local_block_dec}"
  echo "External block: ${external_block_dec}"

  if [ "${local_block_dec}" -eq "${external_block_dec}" ]; then
    echo "Local and external nodes are even."
  elif [ "${local_block_dec}" -gt "${external_block_dec}" ]; then
    difference=$((local_block_dec - external_block_dec))
    echo "Local node is ahead by ${difference} blocks."
  else
    difference=$((external_block_dec - local_block_dec))
    echo "Local node is behind by ${difference} blocks."
  fi

  sleep 60
done
