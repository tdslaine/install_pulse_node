<div align="center">
   
<img src="https://github-production-user-asset-6210df.s3.amazonaws.com/46573429/238115944-7791dc23-8150-459b-b07e-28a4c05345f6.png" style="max-width: 100%; margin: 0 auto;"/>
</div>


## AIO Interactive Setup
Pulse-Chain Unleashed: Experience the Harmony of Effortless Innovation and Peace of Mind with this interactive setup script 

## Installing and Running a Pulsechain Node/Validator + Prometheus/Grafana Monitoring

<small>This setup is split into three parts to provide greater flexibility for users based on their needs.

The first part is the node setup, which involves setting up the core node infrastructure. This includes installing necessary packages and dependencies to run a node. (`setup_pulse_node.sh`)

The second part is the validator setup, which involves configuring the node as a validator, setting up validators keys,wallets, and importing those. (`setup_validator.sh`)

The third part is the monitoring setup, which involves setting up Prometheus/Grafana to keep track of the node and its performance via webinterface. (`setup_monitoring.sh`)

You can run each step individually, based on your requirements, by calling the appropriate setup_###.sh script. This provides a convenient way to install and configure only the necessary components.

Additionally, it's worth noting that after completing each installation step, you'll be prompted to continue with the next setup. This means that there's no need to run each script separately, as the setup process will guide you through each step in sequence.

This streamlined approach ensures that you have a smooth and hassle-free setup experience, and can get up and running quickly. </small>

#####  I am currently validating on the testnet and am hoping to expand my validator node to the mainnet as well. Donations are appreciated and will help cover the costs of running and maintaining the validator node, including staking requirements and infrastructure expenses. If you're interested in contributing, you can make a donation. Thank you for your support!

Ethereum (ETH) &#x039E; & (PRC20) : `0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA`

## |#| Prerequisites

- A Unix-based operating system (e.g., Ubuntu, Debian)
- Git installed

# - Installation Steps -

### One command

```bash
sudo apt update && sudo apt install git -y && git clone https://github.com/tdslaine/install_pulse_node && cd install_pulse_node && chmod +x setup_pulse_node.sh && ./setup_pulse_node.sh
```

### Separate commands
### 1. Install Git** (if not already installed) 


To install Git on a Unix-based system, you can use the package manager specific to your operating system. For example, on Ubuntu or Debian, you can use the following command:

 ```bash
   sudo apt update
 ```
 
```bash
  sudo apt-get install git
```
### 2. Clone the repository

Open the terminal and navigate to the directory where you want to download the repository. Then, use the following command to clone the repository:

```bash
  git clone https://github.com/tdslaine/install_pulse_node
```
### 3. Change directory

Change to the `install_pulse_node` directory:

```bash
  cd install_pulse_node
```

### 4. Modify script permissions

Give execution permissions to the `setup_pulse_node.sh` script:

```bash
  chmod +x setup_pulse_node.sh
```

### 5. Run the script

Finally, run the `setup_pulse_node.sh` script:
```bash
./setup_pulse_node.sh
```

### 6. After the setup is complete

The setup will create several start_###.sh scripts inside the folder you chose in the setup (default: /blockchain), these are:

```bash
start_execution.sh
start_consensus.sh
start_validator.sh
```

There will also be copys of a couple helper-scripts that should ease up the tasks for:

key-managment,

editing configs, 

viewing/following logs,

stopping, restarting and updating the Docker Images.

Most prominent and you goto for general "housekeeping" should be plsmenu
You can call plsmenu from anywhere in your terminal or use the "Validator Menu" Icon from Desktop if you opted to generate one during setup.
Plsmenu combines most of the Tasks one could need for the validator in one place.

```bash
plsmenu
```


## |#| Prometheus/Grafana Monitoring:

### Setup

:exclamation: If you opted not to run the monitoring setup during the validator setup, follow these steps:

Make the `setup_monitoring.sh` script executable: 
```bash 
sudo chmod +x setup_monitoring.sh
```
Run the `setup_monitoring.sh` script to start the Prometheus and Grafana Docker containers: 
```bash 
./setup_monitoring.sh
```
### Adding Dashboards

After the containers have started, open Grafana in your browser at:

```bash
http://127.0.0.1:3000
```
Log in to Grafana with the following credentials:
    -   User: `admin`
    -   Password: `admin`
To add dashboards, navigate to:
```bash 
http://127.0.0.1:3000/dashboard/import
```
Import the JSON files from your setup target directory (default: `/blockchain/Dashboards` - these were downloaded during the setup process).

That's it! Prometheus and Grafana should now be up and running on your machine, allowing you to import more dashboards tailored to your needs.

### Allow Access from within your local Network
:exclamation: If you opted not to allow access from within your local-network to Grafana during the monitoring setup, follow these steps:

1. Find current local IP-Range:
To find your own IP address range, you can use the `hostname -I` command. Open a terminal and enter the following command:

```bash
sudo hostname -I | awk '{print $1}'
```
This will display your IP address

2. Set UFW Rule:
To allow access to the Grafana dashboard within your local subnet, run the ufw command with the appropriate IP range. For example, if your local IP address is 192.168.0.10, you can allow the entire IP range of 192.168.0.0-192.168.0.254 to access port 3000 by using the following command:

```bash
sudo ufw allow from 192.168.0.0/24 to any port 3000
```
Once done, you can reload your firewall and should be able to access your grafana interface via http://IP_FROM_NODE:3000

```bash
sudo ufw reload
```

## |#| Managing Node-Clients

### Launching

:exclamation: This only applies if you didn't choose to autostart the scripts during the setup script when asked if you want to start them now!

After completing the initial setup, you will have to run each `start_###.sh` script at least once manually. Once you have done so, the Docker container will automatically restart in the event of a reboot or crash, without requiring manual intervention. You will only need to run the scripts manually again if you have manually stopped the containers.

cd into the folder you provided in the setup (default: `/blockchain`) f.e.:

```bash
cd /blockchain

./start_execution.sh
./start_consensus.sh
./start_validator.sh
```

### Logging:

To view the log files for the execution, beacon, and validator after a reboot you can use the provided log_viewer.sh or tmux_logviewer.sh script that should be inside the folder you chose in the setup (default: /blockchain) You can also use sepperate commands inside a terminal:

### A) via script:
There are two version available:
1. log_viewer.sh for GUI-Ubuntu
2. tmux_logviewer.sh for terminal-based environments (please get to know on how to control tmux prior).

The script should already be executable, if not make the script executable via:

```bash
cd /blockhain
sudo chmod +x log_viewer.sh
```
or

```bash
cd /blockhain
sudo chmod +x tmux_logviewer.sh
```
run the script:

```bash
cd /blockchain
./log_viewer.sh
```

or

```bash
cd /blockchain
./tmux_logviewer.sh
```

### B) single commands:
```bash
docker logs -f execution
docker logs -f beacon
docker logs -f validator
```

### Stopping/Restarting Containers:

Should you need to alter the original start_###.sh scripts you might need to stop/restart the docker-containers/images that are currently running. To achieve this, you can use the stop_docker.sh/ restart_docker.sh script provided which should be inside the folder you chose in the setup (default: /blockchain).

#### A) via script:

The scripts should already be executable, if not make the script executable via:

```bash
cd /blockchain/helper

sudo chmod +x stop_docker.sh

or

sudo chmod +x restart_docker.sh
```

run the script:
```bash
cd /blockchain/helper

./stop_docker.sh

or

./restart_docker.sh
```

#### B) single commands:

```bash
sudo docker stop -t 300 execution
sudo docker stop -t 180 beacon
sudo docker stop -t 180 validator
```

```bash
sudo docker -rm execution
sudo docker -rm beacon
sudo docker -rm validator
```

Once the containers are stopped, you might also need to prune/clean the cache using the command:

```bash
sudo docker container prune -f
```

After you made desired changes, you can start the Docker Images/Containers again with the initial start_###.sh scripts from within the folder you chose in the setup (default: /blockchain):

```bash
cd /blockchain

./start_execution.sh
./start_consensus.sh
./start_validator.sh
```

## |#| Modifying flags/options

If you ever find yourself in the need to change/add/remove some option-flags or alter the config you can achieve this by first stopping the docker-images/containers, then editing the start_###.sh script as you desire. You can use any editor available, just make sure you run these as sudo to be able to save changes inside the .sh file. Also pay attention to end each line with a \ 


1. Edit desired start_###.sh script

```bash
cd \blockchain

sudo nano start_execution.sh
```

2. save changes
3. restart the docker container-images as described above manually via f.e.

```bash
sudo docker restart execution
```

## |#| Updating the Nodes Docker-Images

To update your Docker containers/images you can use the provided the `update_docker.sh` or simply `restart_docker.sh` script which can be found inside the folder you chose in the setup (default: /blockchain/helper) or use the plsmenu (Validator-Menu Shortcut on Dekstop):

```bash
plsmenu
```

```bash
cd /blockchain/helper

./update_docker.sh
```

Review the output: 

The script will automatically check for updates and update the necessary containers and images. Review the output of the script to ensure that the update process was successful.

###### Note: that the update_docker script might require administrative privileges to execute. If necessary, use sudo to run the script with elevated privileges:

``` bash
cd /blockchain/helper

sudo ./update_docker.sh
```

## |#| Reverting to an Older Docker Image Version

In case a recent update to the Geth or Lighthouse Docker image causes issues, you can follow these steps to revert to a previous, stable version (e.g., v2.0.0):

1. Stop the running Docker clients: Execute the appropriate stop command or use docker stop with the container name or ID.

2. Edit the corresponding start_###.sh script: Choose the appropriate script from start_execution.sh, start_consensus.sh, or start_validator.sh. Modify the line that refers to the Docker image, changing the image version from :latest to the desired older version. For this example in start_execution.sh:

Change this line:
```bash
registry.gitlab.com/pulsechaincom/go-pulse:latest
```
To:
```bash
registry.gitlab.com/pulsechaincom/go-pulse:v2.0.0
```
3. Save the changes and restart the appropriate client: Execute the modified start_###.sh script to restart the client with the older Docker image version.

By following these steps, you can revert to a previous, stable version of the Docker image and continue working without disruption. Be sure to communicate any changes made to the team to maintain consistency across your systems.

Note: you can find the version history for each docker-image on the gitlab https://gitlab.com/pulsechaincom from the pulsedevs.
For example for geth it would be: https://gitlab.com/pulsechaincom/go-pulse/container_registry/2121084 - you have to click next until you are at the last page.
###### howto get there: On the Page, choose your desired client > on left side navigation Panel click "Packages and registries" > then click "Packages and registries" 



### Resources:

Official Homepage: https://pulsechain.com/

Official Gitlab: https://gitlab.com/pulsechaincom

Validator-Launchpad: https://launchpad.pulsechain.com/en/overview

Checkpoint: https://checkpoint.pulsechain.com/

Pulsedev Telegram: https://t.me/PulseDEV

--------------------------------------------------------------------------------------------

ssh: https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04

ssh-tunneling: https://linuxize.com/post/how-to-setup-ssh-tunneling/

ufw: https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04

tmux: https://tmuxcheatsheet.com/
