# v.0.1 - Testing the monitoring add-on for my original install_pulse_node/validator script... this IS STILL in testing but should work !
# flags needed in the start_xyz.sh scripts:
# --pprof --metrics for start_execution.sh
# --metrics for start_consensus.sh and start_validator.sh
# docker container needs to be restartet in order to run with the flags

start_dir=$(pwd)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Create users
echo "Adding users for prometheus and grafana"
sudo useradd -M -G docker prometheus
sudo useradd -M -G docker grafana


# Prompt the user for the location to store prometheus.yml (default: /blockchain)
read -p "Enter the location to store prometheus.yml (default: /blockchain): " config_location

# Set the default location to /blockchain if nothing is entered
if [ -z "$config_location" ]; then
  config_location="/blockchain"
fi

# Create directories
echo "creating directorys for the prometheus and grafana container"
sudo mkdir -p "$config_location/prometheus"
sudo mkdir -p "$config_location/grafana"

# Define the yml content
PROMETHEUS_YML="global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'nodes'
     metrics_path: /metrics
     static_configs:
       - targets: ['localhost:5054']
   - job_name: 'validators'
     metrics_path: /metrics
     static_configs:
       - targets: ['localhost:5064']
   - job_name: 'geth'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /debug/metrics/prometheus
     scheme: http
     static_configs:
     - targets: ['localhost:6060']"
	 
	 
# Create prometheus.yml file
echo "creating the yml file for promethesu"
sudo bash -c "cat > $config_location/prometheus.yml << 'EOF'
$PROMETHEUS_YML
EOF"


# Set ownership and permissions
echo "setting ownership for container-folders"
sudo chown -R prometheus:prometheus "$config_location/prometheus"
sudo chown -R grafana:grafana "$config_location/grafana"
sudo chmod 644 "$config_location/prometheus.yml"
sudo chmod -R 777 "$config_location/grafana"

# Set UFW Rules
echo "setting up firewall rules to allow local connection for metric ports"
sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
sudo ufw allow from 127.0.0.1 to any port 8546 proto tcp
sudo ufw allow from 127.0.0.1 to any port 5052 proto tcp
sudo ufw allow from 127.0.0.1 to any port 5064 proto tcp

# Define Docker commands as variables
PROMETHEUS_CMD="sudo -u prometheus docker run -dt --name prometheus --restart=always \\
  --net='host' \\
  -v $config_location/prometheus.yml:/etc/prometheus/prometheus.yml \\
  -v $config_location/prometheus:/prometheus-data \\
  prom/prometheus
  
  "

PROMETHEUS_NODE_CMD="sudo -u prometheus docker run -dt --name node_exporter --restart=always \\
  --net='host' \\
  -v '/:/host:ro,rslave' \\
  prom/node-exporter --path.rootfs=/host 
  
  "

GRAFANA_CMD="sudo -u grafana docker run -dt --name grafana --restart=always \\
  --net='host' \\
  -v $config_location/grafana:/var/lib/grafana \\
  grafana/grafana
  
  "

# Create start_monitoring.sh script
echo "creating start_monitor.sh script"
sudo bash -c "cat > $config_location/start_monitoring.sh << 'EOF'
#!/bin/bash

$PROMETHEUS_CMD
$PROMETHEUS_NODE_CMD
$GRAFANA_CMD
EOF"

# Make start_monitoring.sh executable
sudo chmod +x $config_location/start_monitoring.sh

echo "created Monitoring-Scripts and Set Firewall rules"
cd $config_location
echo "..."
sleep 2

echo "launching prometheus, node-exporter and grafana containers"
echo ""
sudo $config_location/start_monitoring.sh
sleep 2

# checking if they are running 
echo ""
echo "checking if the docker started" 
echo ""
if sudo docker ps --format '{{.Names}}' | grep -q '^grafana$'; then
  echo "Grafana container is running"
else
  echo "Grafana container is not running"
fi
echo ""
if sudo docker ps --format '{{.Names}}' | grep -q '^prometheus$'; then
  echo "Prometheus container is running"
else
  echo "Prometheus container is not running"
fi
echo ""
if sudo docker ps --format '{{.Names}}' | grep -q '^node_exporter$'; then
  echo "Node Exporter container is running"
else
  echo "Node Exporter container is not running"
fi
echo ""

echo "..."
sleep 2

# Set variables for the API endpoint, authentication, and datasource configuration
grafana_api="http://localhost:3000/api/datasources"
grafana_auth="admin:admin"
prometheus_url="http://localhost:9090"
datasource_name="Prometheus"
datasource_type="prometheus"
access_mode="proxy"
basic_auth_user=""
basic_auth_password=""
is_default="true"

# Send the POST request to add the datasource using curl
curl -X POST -H "Content-Type: application/json" -d \
'{
    "name": "'$datasource_name'",
    "type": "'$datasource_type'",
    "url": "'$prometheus_url'",
    "access": "'$access_mode'",
    "basicAuthUser": "'$basic_auth_user'",
    "basicAuthPassword": "'$basic_auth_password'",
    "isDefault": '$is_default'
}' \
--user "$grafana_auth" \
$grafana_api

sleep 1
echo ""

echo "Downloading dashboard JSON..."
wget -qO- https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/dashboard.json > "${start_dir}/Geth_dashboard.json"
wget -qO- https://grafana.com/api/dashboards/11074/revisions/9/download > "${start_dir}/System_dashboard.json"
wget -qO- https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json > "${start_dir}/Lighthouse_beacon_dashboard.json"
wget -qO- https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json > "${start_dir}/Lighthouse_validator_dashboard.json"
wget -qO- https://raw.githubusercontent.com/raskitoma/pulse-staking-dashboard/main/Yoldark_ETH_staking_dashboard.json > "${start_dir}/Staking_dashboard.json"
echo ""
echo "Shoutouts to raskitoma (@raskitoma) for forking the Yoldark_ETH_staking_dashboard. His Github can be found here: https://github.com/raskitoma/pulse-staking-dashboard"
echo "Shoutouts to Jexxa (@JexxaJ) for providing further improvments of the dashboard."
echo "Shoutouts to @rainbowtopgun for alpha/beta testing and providing awesome feedback while tuning the scripts" 
echo ""
echo "THIS COMMUNITY IS AWESOME !!!"
echo "..."
sleep 5
echo ""
echo "Dashboard Download complete."
echo ""
echo ""
#echo "Required flags for scripts:"
#echo " - start_execution.sh: --metrics --pprof"
#echo " - start_consensus.sh: --staking --metrics --validator-monitor-auto"
#echo " - start_validator.sh: --metrics"
#echo ""
#echo "Restart containers with:"
#echo " - sudo docker restart execution"
#echo " - sudo docker restart beacon"
#echo " - sudo docker restart validator"
#echo ""
#echo ""

echo "Do you want to add the required flags to the start_xyz.sh scripts The Docker images will restart? (y/n)"
read answer

if [[ $answer == "y" ]]; then

  # Update start_execution.sh script
  if [ -f "${config_location}/start_execution.sh" ]; then
    sudo sed -i '14s:^:--metrics \\\n:' "${config_location}/start_execution.sh"
    sudo sed -i '15s:^:--pprof \\\n:' "${config_location}/start_execution.sh"
    echo "Updated start_execution.sh with --metrics and --pprof flags."
  else
    echo "start_execution.sh not found. Skipping."

  fi

  # Update start_consensus.sh script
  if [ -f "${config_location}/start_consensus.sh" ]; then
    sudo sed -i '14s:^:--metrics \\\n:' "${config_location}/start_consensus.sh"
    sudo sed -i '15s:^:--staking \\\n:' "${config_location}/start_consensus.sh"
    sudo sed -i '16s:^:--validator-monitor-auto \\\n:' "${config_location}/start_consensus.sh"
    echo "Updated start_consensus.sh with --metrics, --staking, and --validator-monitor-auto flags."
  else
    echo "start_consensus.sh not found. Skipping."
  fi

  # Update start_validator.sh script
  if [ -f "${config_location}/start_validator.sh" ]; then
    sudo sed -i '7s:^:--metrics \\\n:' "${config_location}/start_validator.sh"
    echo "Updated start_validator.sh with --metrics flag."
  else
    echo "start_validator.sh not found. Skipping."
  fi
else
    echo "Make sure you have these in your startup Commands"
    echo "Required flags for scripts:"
    echo " - start_execution.sh: --metrics --pprof"
    echo " - start_consensus.sh: --staking --metrics --validator-monitor-auto"
    echo " - start_validator.sh: --metrics"
    echo ""
    echo "Restart containers with:"
    echo " - sudo docker restart execution"
    echo " - sudo docker restart beacon"
    echo " - sudo docker restart validator"
    echo ""
    echo ""
  fi

  echo "Script finished. Check your files for updates."
  
  echo "Restarting Docker containers..."

  sudo docker restart execution
  sudo docker restart beacon
  sudo docker restart validator

  echo "Docker containers restarted successfully."

echo "..."
sleep 2
echo "..."
echo -e "${GREEN} - Congratulations, setup is now complete.${NC}"
echo ""
echo -e "${GREEN} ** If you found this script helpful and would like to show your appreciation, donations are accepted via ERC20 at the following address: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA"
echo ""

echo "Brought to you by:
  ██████__██_██████__███████_██_______█████__██____██_███████_██████__
  ██___██_██_██___██_██______██______██___██__██__██__██______██___██_
  ██___██_██_██████__███████_██______███████___████___█████___██████__
  ██___██_██_██___________██_██______██___██____██____██______██___██_
  ██████__██_██______███████_███████_██___██____██____███████_██___██_"
  sleep 1
exit 0
