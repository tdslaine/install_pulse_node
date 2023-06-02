#!/bin/bash

    echo "Stopping Docker-images..."
    docker stop -t 300 execution
    docker stop -t 180 beacon
    docker stop -t 180 validator
    docker container prune -f && docker image prune -f
    echo "Removing Docker-images..."
    docker rmi registry.gitlab.com/pulsechaincom/go-pulse
    docker rmi registry.gitlab.com/pulsechaincom/erigon-pulse
    docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse 
    docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain
    docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/validator
    #docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl
    

   
