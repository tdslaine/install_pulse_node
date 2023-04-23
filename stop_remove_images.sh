#!/bin/bash

sudo docker stop execution
sudo docker stop beacon
sudo docker stop validator

sudo docker rm execution
sudo docker rm beacon
sudo docker rm validator

sudo docker container prune -f
