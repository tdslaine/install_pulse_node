#!/bin/bash

# Fetch all running container IDs
containers=$(docker ps -q)

if [ -z "$containers" ]; then
    echo "No running Docker containers found."
else
    # Stop all running containers
    echo "Stopping all running Docker containers..."
    docker stop $containers
    echo "All running Docker containers have been stopped."
fi
