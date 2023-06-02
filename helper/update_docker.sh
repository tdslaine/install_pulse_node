#!/bin/bash

    echo "Stopping Docker-images..."
    docker stop -t 300 execution
    docker stop -t 180 beacon
    docker stop -t 180 validator
    docker container prune -f && docker image prune -f
    echo "Restarting docker images from script..."
   
