#!/bin/bash

# Fetch all image names and tags
images=$(docker images --format '{{.Repository}}:{{.Tag}}')

# Pull the latest version of each image
for image in $images; do
    echo "Updating $image"
    docker pull $image
done

echo "All Docker images have been updated."
