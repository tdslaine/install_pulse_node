<div align="center">
   
<img src="https://user-images.githubusercontent.com/46573429/233395501-99a54d99-7184-4d96-9d00-7b82f9da3939.png" style="max-width: 100%; margin: 0 auto;"/>
</div>

## AIO Interactive Setup
Pulse-Chain Unleashed: Experience the Harmony of Effortless Innovation and Peace of Mind with this interactive setup script 

## Installing and Running a Pulsechain Node with an optional Lighthouse Validator and Prometheus/Grafana Monitoring

This setup is split into three parts to provide greater flexibility for users based on their needs.

The first part is the node setup, which involves setting up the core node infrastructure. This includes installing necessary packages and dependencies to run a node. (`setup_pulse_node.sh`)

The second part is the validator setup, which involves configuring the node as a validator, setting up validators keys,wallets, and importing those. (`setup_validator.sh`)

The third part is the monitoring setup, which involves setting up Prometheus/Grafana to keep track of the node and its performance via webinterface. (`setup_monitoring.sh`)

You can run each step individually, based on your requirements, by calling the appropriate setup_###.sh script. This provides a convenient way to install and configure only the necessary components.

Additionally, it's worth noting that after completing each installation step, you'll be prompted to continue with the next setup. This means that there's no need to run each script separately, as the setup process will guide you through each step in sequence.

This streamlined approach ensures that you have a smooth and hassle-free setup experience, and can get up and running quickly.

#####  I am currently validating on the testnet and am hoping to expand my validator node to the mainnet as well. Donations are appreciated and will help cover the costs of running and maintaining the validator node, including staking requirements and infrastructure expenses. If you're interested in contributing, you can make a donation. Thank you for your support!

Ethereum (ETH) &#x039E; : `0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA`

## Prerequisites

- A Unix-based operating system (e.g., Ubuntu, Debian)
- Git installed

# - Installation Steps -

### 1. Install Git** (if not already installed) 


To install Git on a Unix-based system, you can use the package manager specific to your operating system. For example, on Ubuntu or Debian, you can use the following command:

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
  sudo ./setup_pulse_node.sh
```

### 6. After the setup is complete

The setup will create several start_###.sh scripts inside the folder you chose in the setup (default: /blockchain), these are:

```bash
start_execution.sh
start_consensus.sh
start_validator.sh
```

There will also be a copy of three helper_scripts to ease up the task of stopping, viewing/following logs and updating the Docker Images/Containers. Read bellow for further informaion


## Prometheus/Grafana Monitoring:
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
Import the JSON files from your local install_pulse_node directory (default: `/blockchain/Dashboards` - these were downloaded during the setup process).

That's it! Prometheus and Grafana should now be up and running on your machine, allowing you to import more dashboards tailored to your needs.


## Launching, Logging, and Stopping the Execution, Beacon and Validator Docker-Containers

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

## Logging:

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
sudo docker logs -f execution
sudo docker logs -f beacon
sudo docker logs -f validator
```

## Stopping/Restarting Containers:

Should you need to alter the original start_###.sh scripts you might need to stop/restart the docker-containers/images that are currently running. To achieve this, you can use the stop_docker.sh/ restart_docker.sh script provided which should be inside the folder you chose in the setup (default: /blockchain).

### A) via script:

The scripts should already be executable, if not make the script executable via:

```bash
cd /blockchain

sudo chmod +x stop_docker.sh

or

sudo chmod +x restart_docker.sh
```

run the script:
```bash
cd /blockchain

./stop_docker.sh

or

./restart_docker.sh
```

### B) singel commands:

```bash
sudo docker stop execution
sudo docker stop beacon
sudo docker stop validator
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

## Changing flags/options

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

## Updating the Docker-Images

To update your Docker containers/images you can use the provided the update_docker.sh script which can be found inside the folder you chose in the setup (default: /blockchain):

The script should already be executable, if not make the script executable via::

```bash
cd /blockchain

chmod +x update_docker.sh
```

Run the script: 

```bash
cd /blockchain

./update_docker.sh
```

Review the output: 

The script will automatically check for updates and update the necessary containers and images. Review the output of the script to ensure that the update process was successful.

### Please note that the watchtower.sh script might require administrative privileges to execute, depending on your system's settings. If necessary, use sudo to run the script with elevated privileges:

``` bash
cd /blockchain

sudo ./watchtower.sh
```
### Ressources:

Pulse:

official gitlab: https://gitlab.com/pulsechaincom

validator launchpad: https://launchpad.v4.testnet.pulsechain.com/en/overview

pulsedev telegram: https://t.me/PulseDEV


ssh: https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04

ssh-tunneling (usefull for secure RPC acces, would be port 8545): https://linuxize.com/post/how-to-setup-ssh-tunneling/

ufw (firewall): https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04

tmux: https://tmuxcheatsheet.com/
