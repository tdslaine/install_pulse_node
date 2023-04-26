#!/bin/bash

# Stop Docker containers
sudo docker stop grafana prometheus node_exporter

# Remove Containers
sudo docker rm grafana prometheus node_exporter

# Remove stopped containers
sudo docker container prune -f

# Remove Prometheus and Grafana users
sudo userdel prometheus
sudo userdel grafana

# Remove Prometheus and Grafana data directories
sudo rm -R /blockchain/prometheus
sudo rm -R /blockchain/grafana

# Remove Prometheus configuration file
sudo rm /blockchain/prometheus.yml
sudo rm /blockchain/start_monitoring.sh
