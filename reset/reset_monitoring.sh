#!/bin/bash

TABLE="\
+-------------------------------------------------------------+
| This script will remove all Prometheus/Grafana related      |
| changes.                                                    |
|                                                             |
| Do you want to continue (y/n)?                              |
+-------------------------------------------------------------+
| If yes, the following actions will be taken:                |
|                                                             |
| 1. Stop Docker containers                                   |
| 2. Remove Containers                                        |
| 3. Remove stopped containers                                |
| 4. Remove Prometheus and Grafana users                      |
| 5. Remove Prometheus and Grafana data directories           |
| 6. Remove Prometheus configuration file                     |
|                                                             |
| Are you sure you want to continue (y/n)?                    |
+-------------------------------------------------------------+

"
clear
echo "$TABLE"
read -p "Enter 'y' to continue or 'n' to cancel: " answer

if [[ $answer == "y" ]] || [[ $answer == "Y" ]]; then
    echo "Resetting and removing files..."

    # Stop Docker containers
    sudo docker stop grafana prometheus node_exporter

    # Remove Containers
    sudo docker rm grafana prometheus node_exporter

    # Remove stopped containers
    sudo docker container prune -f
    sudo docker rmi grafana/grafana 
    sudo docker rmi prom/prometheus 
    sudo docker rmi curlimages/curl
    sudo docker rmi prom/node-exporter
    
    # Remove Prometheus and Grafana users
    sudo userdel prometheus
    sudo userdel grafana

    # Remove Prometheus and Grafana data directories
    sudo rm -R /blockchain/prometheus
    sudo rm -R /blockchain/grafana

    # Remove Prometheus configuration file
    sudo rm /blockchain/prometheus.yml
    sudo rm /blockchain/start_monitoring.sh
else
    echo "Exiting the script."
    exit 0
fi
