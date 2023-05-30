#!/bin/bash

docker stop -t 300 execution
docker stop -t 300 geth
docker stop -t 180 beacon
docker stop -t 180 validator

# Pull the latest watchtower image
echo "Pulling the latest watchtower image..."
docker pull containrrr/watchtower

# Launch watchtower container with the --run-once flag
echo "Launching watchtower with the --run-once flag..."
docker run \
    -d \
    --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
    --run-once \
    --include-stopped \
    --include-restarting \
    --revive-stopped \
    geth \
    execution \
    beacon \
    validator

echo "Watchtower run-once process has completed."
