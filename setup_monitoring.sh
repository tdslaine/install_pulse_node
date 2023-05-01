
# v0.3

# modified to add support prysm client too... dashboards are from eth - so they might not work


start_dir=$(pwd)
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function tab_autocomplete(){
    
    # Enable tab autocompletion for the read command if line editing is enabled
    if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ] && [ -t 0 ]; then
        bind '"\t":menu-complete'
    fi
}


function get_user_choices() {
    echo "Choose your Client"
    echo ""
    echo "1. Lighthouse"
    echo "2. Prysm"
    echo ""

    # loop until a valid input is entered
    while true; do
        read -p "Enter your choice (1 or 2): " client_choice

        # check if input is valid
        if [[ "$client_choice" == "1" || "$client_choice" == "2" ]]; then
            break
        else
            echo "Invalid input. Please enter 1 or 2."
        fi
    done

    echo "${client_choice}"
}


function log_viewer_choice() {
    while true; do
        read -e -p "$(echo -e "${GREEN}Would you like to start the logviewer to monitor the client logs? [y/n]:${NC}")" log_it

        if [[ "$log_it" =~ ^[Yy]$ ]]; then
            echo "Choose a log viewer:"
            echo "1. GUI/TAB Based Logviewer (separate tabs; easy)"
            echo "2. TMUX Logviewer (AIO logs; advanced)"
            echo "3. Cancel"

            read -p "Enter your choice (1, 2, or 3): " choice

            case $choice in
                1)
                    ${INSTALL_PATH}/log_viewer.sh
                    break
                    ;;
                2)
                    ${INSTALL_PATH}/tmux_logviewer.sh
                    break
                    ;;
                3)
                    echo "Canceled."
                    break
                    ;;
                *)
                    echo "Invalid choice. Please try again."
                    ;;
            esac
        else
            echo "Logviewer not started."
            break
        fi
    done
}





clear

# Create users
echo "Adding users for prometheus and grafana"
sudo useradd -M -G docker prometheus
sudo useradd -M -G docker grafana


# Prompt the user for the location to store prometheus.yml (default: /blockchain)
read -e -p "Enter the location to store prometheus.yml (default: /blockchain):" INSTALL_PATH


# Set the default location to /blockchain if nothing is entered
if [ -z "$INSTALL_PATH" ]; then
  INSTALL_PATH="/blockchain"
fi

get_user_choices

# Create directories
echo ""
echo "Creating directories for the prometheus and grafana container"
sudo mkdir -p "$INSTALL_PATH/prometheus"
sudo mkdir -p "$INSTALL_PATH/grafana"

  if [[ "$client_choice" == "1" ]]; then
  
  # Define the yml content for use with lighthouse
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

	elif  [[ "$client_choice" == "2" ]]; then
  PROMETHEUS_YML="global:
  scrape_interval:     15s # By default, scrape targets every 15 seconds.

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
   - job_name: 'node_exporter'
     static_configs:
       - targets: ['localhost:9100']
   - job_name: 'validator'
     static_configs:
       - targets: ['localhost:8081']
   - job_name: 'beacon node'
     static_configs:
       - targets: ['localhost:8080']
   - job_name: 'slasher'
     static_configs:
       - targets: ['localhost:8082']
   - job_name: 'geth'
     scrape_interval: 15s
     scrape_timeout: 10s
     metrics_path: /debug/metrics/prometheus
     scheme: http
     static_configs:
       - targets: ['localhost:6060']"
  fi

	 
# Create prometheus.yml file
echo ""
echo "Creating the yml file for prometheus"
sudo bash -c "cat > $INSTALL_PATH/prometheus.yml << 'EOF'
$PROMETHEUS_YML
EOF"


# Set ownership and permissions
echo ""
echo "Setting ownership for container-folders"
sudo chown -R prometheus:prometheus "$INSTALL_PATH/prometheus"
sudo chown -R grafana:grafana "$INSTALL_PATH/grafana"
sudo chmod 644 "$INSTALL_PATH/prometheus.yml"
sudo chmod -R 777 "$INSTALL_PATH/grafana"

# Set UFW Rules as we bind the docker network to the host  (deny all incomming traffic has been set prev. in the Node/Validator-Setup)
echo ""
echo "Setting up firewall rules to allow local connection to metric ports"
sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
sudo ufw allow from 127.0.0.1 to any port 8546 proto tcp
sudo ufw allow from 127.0.0.1 to any port 9090 proto tcp
sudo ufw allow from 127.0.0.1 to any port 9100 proto tcp
sudo ufw allow from 127.0.0.1 to any port 6060 proto tcp

if [[ "$client_choice" == "1" ]]; then
  sudo ufw allow from 127.0.0.1 to any port 5052 proto tcp
  sudo ufw allow from 127.0.0.1 to any port 5064 proto tcp

elif [[ "$client_choice" == "2" ]]; then
  sudo ufw allow from 127.0.0.1 to any port 8081 proto tcp
  sudo ufw allow from 127.0.0.1 to any port 8080 proto tcp
  sudo ufw allow from 127.0.0.1 to any port 8082 proto tcp
fi
# Prompt to allow access to Grafana Dashboard in Local Network

function get_local_ip() {
  local_ip=$(hostname -I | awk '{print $1}')
  echo $local_ip
}

function get_ip_range() {
  local_ip=$(get_local_ip)
  ip_parts=(${local_ip//./ })
  ip_range="${ip_parts[0]}.${ip_parts[1]}.${ip_parts[2]}.0/24"
  echo $ip_range
}

#debug
local_ip_debug=$(hostname -I | awk '{print $1}')
ip_range=$(get_ip_range)

echo ""
echo "Your Current IP is: $local_ip_debug"
echo ""
read -p "Do you want to allow access to the Grafana Dashboard from within your local network ($ip_range)? (y/n): " local_network_choice
echo ""


if [[ $local_network_choice == "y" ]]; then
    echo ""
    sudo ufw allow from $ip_range to any port 3000 proto tcp comment 'Grafana Port for private IP range'
  
fi

echo ""
sudo ufw reload 
echo ""

# Define Docker commands as variables
PROMETHEUS_CMD="sudo -u prometheus docker run -dt --name prometheus --restart=always \\
  --net='host' \\
  -v ${INSTALL_PATH}/prometheus.yml:/etc/prometheus/prometheus.yml \\
  -v ${INSTALL_PATH}/prometheus:/prometheus-data \\
  prom/prometheus
  
  "

PROMETHEUS_NODE_CMD="sudo -u prometheus docker run -dt --name node_exporter --restart=always \\
  --net='host' \\
  -v '/:/host:ro,rslave' \\
  prom/node-exporter --path.rootfs=/host 
  
  "

GRAFANA_CMD="sudo -u grafana docker run -dt --name grafana --restart=always \\
  --net='host' \\
  -v ${INSTALL_PATH}/grafana:/var/lib/grafana \\
  grafana/grafana
  
  "

# Create start_monitoring.sh script
echo ""
echo "Creating start_monitor.sh script"
sudo bash -c "cat > $INSTALL_PATH/start_monitoring.sh << 'EOF'
#!/bin/bash

$PROMETHEUS_CMD
$PROMETHEUS_NODE_CMD
$GRAFANA_CMD
EOF"

# Make start_monitoring.sh executable
sudo chmod +x $INSTALL_PATH/start_monitoring.sh

echo ""
echo "Created Monitoring-Scripts and Set Firewall rules"
cd $INSTALL_PATH
echo "..."
sleep 2

echo ""
echo "Launching prometheus, node-exporter and grafana containers"
echo ""
sudo $INSTALL_PATH/start_monitoring.sh
sleep 2

# checking if they are running 
echo ""
echo "Checking if the docker started" 
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


sudo mkdir -p "${INSTALL_PATH}/Dashboards"
echo "Downloading dashboard JSON..."
sudo wget -qO "${INSTALL_PATH}/Dashboards/002_Geth_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://gist.githubusercontent.com/karalabe/e7ca79abdec54755ceae09c08bd090cd/raw/dashboard.json > /dev/null
sudo wget -qO "${INSTALL_PATH}/Dashboards/003_System_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://grafana.com/api/dashboards/11074/revisions/9/download > /dev/null

if [[ "$client_choice" == "1" ]]; then
sudo wget -qO "${INSTALL_PATH}/Dashboards/004_Lighthouse_beacon_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/Summary.json > /dev/null
sudo wget -qO "${INSTALL_PATH}/Dashboards/005_Lighthouse_validator_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://raw.githubusercontent.com/sigp/lighthouse-metrics/master/dashboards/ValidatorClient.json > /dev/null
sudo wget -qO "${INSTALL_PATH}/Dashboards/001_Staking_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://raw.githubusercontent.com/raskitoma/pulse-staking-dashboard/main/Yoldark_ETH_staking_dashboard.json > /dev/null

elif [[ "$client_choice" == "2" ]]; then
sudo wget -qO "${INSTALL_PATH}/Dashboards/001_Prysm_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://raw.githubusercontent.com/GuillaumeMiralles/prysm-grafana-dashboard/master/less_10_validators.json > /dev/null
sudo wget -qO "${INSTALL_PATH}/Dashboards/000_Prysm_dashboard.json" -P "${INSTALL_PATH}/Dashboards" https://raw.githubusercontent.com/metanull-operator/eth2-grafana/master/eth2-grafana-dashboard-single-source-beacon_node.json > /dev/null

fi

echo ""
echo ""
sudo chmod -R 755 "${INSTALL_PATH}/Dashboards"
sleep 1

clear
echo ""
echo -e "Thanks to ${GREEN}raskitoma (@raskitoma)${NC} for forking the Yoldark_ETH_staking_dashboard. GitHub link: https://github.com/raskitoma/pulse-staking-dashboard"
echo -e "Thanks to ${GREEN}Jexxa (@JexxaJ)${NC} for providing further improvements to the forked dashboard. GitHub link: https://github.com/JexxaJ/Pulsechain-Validator-Script"
echo -e ""
echo -e "BIG Shoutout to ${GREEN}RainbowTopGun (@rainbowtopgun)${NC} for his valuable contributions in alpha/beta testing and providing awesome feedback while refining the scripts."
echo -e "Greetings to the whole plsdev tg-channel, you guys rock"
echo -e ""
echo -e "Crypto world's delight,"
echo -e "Hex and PulseX, side by side,"
echo -e "Hedron, Icosa twine."
echo -e "..."
echo ""
echo -e "Press Enter to continue"
read -p ""
echo ""

echo -e "${GREEN}Congratulations, setup is now complete.${NC}"
echo ""
if [[ $local_network_choice == "y" ]]; then
echo "Access Grafana: http://127.0.0.1:3000 or http://${local_ip_debug}:3000"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Add dashboards via: http://127.0.0.1:3000/dashboard/import or http://${local_ip_debug}:3000/dashboard/import"
echo "Import JSONs from '${INSTALL_PATH}/Dashboards'"
else
echo "Access Grafana: http://127.0.0.1:3000"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Add dashboards via: http://127.0.0.1:3000/dashboard/import"
echo "Import JSONs from '${INSTALL_PATH}/Dashboards'"
fi
echo ""
echo "Brought to you by:
  ██████__██_██████__███████_██_______█████__██____██_███████_██████__
  ██___██_██_██___██_██______██______██___██__██__██__██______██___██_
  ██___██_██_██████__███████_██______███████___████___█████___██████__
  ██___██_██_██___________██_██______██___██____██____██______██___██_
  ██████__██_██______███████_███████_██___██____██____███████_██___██_"
echo -e "${GREEN}For Donations use ERC20: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA${NC}"
echo ""
echo "Press enter to continue..."
read -p ""
echo ""
log_viewer_choice

exit 0
fi
