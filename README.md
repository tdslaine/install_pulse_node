   
<img src="https://github-production-user-asset-6210df.s3.amazonaws.com/46573429/238115944-7791dc23-8150-459b-b07e-28a4c05345f6.png" style="max-width: 100%; margin: 0 auto;"/>
</div>


## AIO Interactive Setup
Pulse-Chain Unleashed: Experience the Harmony of Effortless Innovation and Peace of Mind with this interactive setup script 

####  Donations: Donations are appreciated and will help. Thank you for your support!

(PRC20) : `0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA`

### Info: Current plsmenu version: 1.3b  (updated 09-18-2023)


## Installing and Running a Pulsechain Node/Validator + Prometheus/Grafana Monitoring

<small>This setup is split into three parts to provide greater flexibility for users based on their needs.

The first part is the node setup, which involves setting up the core node infrastructure. This includes installing necessary packages and dependencies to run a node. (`setup_pulse_node.sh`)

The second part is the validator setup, which involves configuring the node as a validator, setting up validators keys,wallets, and importing those. (`setup_validator.sh`)

The third part is the monitoring setup, which involves setting up Prometheus/Grafana to keep track of the node and its performance via webinterface. (`setup_monitoring.sh`)

You can run each step individually, based on your requirements, by calling the appropriate setup_###.sh script. This provides a convenient way to install and configure only the necessary components.

Additionally, it's worth noting that after completing each installation step, you'll be prompted to continue with the next setup. This means that there's no need to run each script separately, as the setup process will guide you through each step in sequence.
   
To prepare dedicated devices for offline-key generation use (`setup_offline_keygen.sh`), this will work on a linux live iso and devices which are meant to stay offline after the initial keygen setup.

This streamlined approach ensures that you have a smooth and hassle-free setup experience, and can get up and running quickly. </small>


## |#| Prerequisites

- A Unix-based operating system (e.g., Ubuntu)

## |#| Installation Steps

### Single-Command

Whole Setup:
```bash
sudo apt update && sudo apt install git -y && git clone https://github.com/tdslaine/install_pulse_node && cd install_pulse_node && chmod +x setup_pulse_node.sh && ./setup_pulse_node.sh
```
Offline-Keygen only:
```bash
sudo apt update && sudo apt install git -y && git clone https://github.com/tdslaine/install_pulse_node && cd install_pulse_node && chmod +x setup_offline_keygen.sh && ./setup_offline_keygen.sh
```
or
```bash
wget https://tinyurl/valikey -O setup_offline_keygen.sh && chmod +x setup_offline_keygen.sh && ./setup_offline_keygen.sh
```

### Manual Steps

#### 1. Install Git** (if not already installed) 

 ```bash
   sudo apt update && sudo apt install git -y
 ```
 
#### 2. Clone the repository

```bash
  git clone https://github.com/tdslaine/install_pulse_node
```

#### 3. Change to the `install_pulse_node` directory:

```bash
  cd install_pulse_node
```

#### 4. Give execution permissions to the `setup_pulse_node.sh` script:

```bash
  chmod +x setup_pulse_node.sh
```

#### 5. Run the `setup_pulse_node.sh` script:

```bash
./setup_pulse_node.sh
```

#### 6. After the initial setup

:exclamation: This only applies if you didn't choose to autostart the scripts during the setup script when asked if you want to start them now! :exclamation:

After completing the initial setup, you will have to run each `start_###.sh` script at least once manually. Once done, the Docker container will automatically restart in the event of a reboot or crash, without requiring manual intervention.

cd into the folder you provided in the setup (default: `/blockchain`):

```bash
cd /blockchain \

./start_execution.sh \
./start_consensus.sh \
./start_validator.sh 
```

#### 7. Make sure your docker-images are running:

```bash
docker ps
```

## |#| Managing Node/Validator

There will be a couple of helper-scripts that should ease up the tasks for key-managment, viewing/following logs, stopping, restarting and updating the Docker Images gracefully, shutting down, restarting and updating the system.

`plsmenu` combines most of these Tasks in one, easy to use menu.

You can call `plsmenu` from anywhere in your terminal or use the "Validator Menu" Icon from Desktop if you opted to generate it during the setup.

```bash
plsmenu
```
-----------------------------------------------------------------
## |#| About validator-keys (keystore file generation):


- User gets prompted to generate/import/restore keys during inital setup of the validator.
- The key generation/managment can be restarted from plsmenu (plsmenu > key mgmt > add/restore keys)  any time.
- Keys can be added at any time into the validator.
- If using the offline keygenerator users can import these keys via plsmenu > key mgmt > add/restore keys any time.

Creating keystore files involves a methodical process designed for generating and managing validator keys, a quick rundown:

1. **Sequential Key Generation (Indexing)**: 
   - **Index-Based Generation**: Keys are generated starting from index 0, with each subsequent key receiving the next sequential index.
   - **User-Defined Key Quantity**: The number of keys to be generated can be specified by the user. The tool creates keys sequentially from the starting index to the designated end index.

2. **Restoration of Previously Generated Keys**: 
   - **Starting Index for Restoration**: To restore previously generated keys, users can set the starting index to the desired key-index from which restoration should begin.
   - **Consistent Generation Order**: The keys will always regenerate in the same sequence as initially created.

3. **Specific Key Restoration**: 
   - **Restoring a Specific Keystore**: To restore a particular validator keystore, set the starting index to one less than the desired keystore index and generate one key.

4. **Deposit File Generation**: 
   - **Session-Based**: The deposit file, crucial for validator registration, is generated per session.

5. **Import Process and Reuse of Keystores**: 
   - **Skipping Imported Keystores**: Keystores already imported into a validator are skipped in subsequent import processes.
   - **Non-Reuse of Exited Validator Keystores**: Once a validator is exited, the associated keystore (or validator index) cannot be reused. This is crucial for maintaining the integrity and security of the network.

Summary:
```bash
1. Initial Generation at Index 0 (Creating 1 Key):
   [Index 0] --> [Create 1 Key] --> [Keystore 1]

2. Sequential Generation from Index 0 to Index X (Creating X+1 Keys):
   [Index 0] --> [Create 1 Key] --> [Keystore 1]
   [Index 1] --> [Create 1 Key] --> [Keystore 2]
   [Index 2] --> [Create 1 Key] --> [Keystore 3]
   ...
   [Index X] --> [Create 1 Key] --> [Keystore X+1]

Example of Creating 5 Keys Starting at Index 3:
   [Index 3] --> [Create 5 Keys] --> [Keystores 4 to 8]
   [Index 3] --> [Keystore 4]
   [Index 4] --> [Keystore 5]
   [Index 5] --> [Keystore 6]
   [Index 6] --> [Keystore 7]
   [Index 7] --> [Keystore 8]

3. Restoration of a Specific Keystore at Index X (Creating 1 Key):
   - To restore Keystore at Index X+1, set starting index to X
   [Index X] --> [Create 1 Key] --> [Restore Keystore X+1]

Example for Restoring Keystore 10 (Creating 1 Key):
   - To restore Keystore 10, set starting index to 9
   [Index 9] --> [Create 1 Key] --> [Restore Keystore 10]

Example of Restoring Multiple Keystores:
   - To restore Keystores 5 to 7, set starting index to 4 and create 3 keys
   [Index 4] --> [Create 3 Keys] --> [Restore Keystores 5 to 7]
   [Index 4] --> [Restore Keystore 5]
   [Index 5] --> [Restore Keystore 6]
   [Index 6] --> [Restore Keystore 7]

```
-----------------------------------------------------------------

## Logging:

To view the log files for the execution, beacon, and validator you can use the generated Desktop-Icons, launch them via plsmenu or call the scripts manually from within the /helper folder (default: /blockchain/helper) or use the docker logs command.

There are two AIO version available. as well as the single, client specific Logs:
1. log_viewer.sh using Gnome-Terminal (Ubuntu GUI-Version)
2. tmux_logviewer.sh using tmux (terminal-based, please get to know on how to control tmux prior).


#### -via plsmenu:

```bash
plsmenu
```

AIO-Logs:
`Logviewer > choose a type of AIO-Log`

Client Specific Logs:
`Logviewer > Clients Menu > desired Client > Show Logs`

-----------------------------------------------------------------

#### -via Desktop Shortcut

if created during setup, just double-click the UI_logs or TMUX_logs -Dekstop Icon.


-----------------------------------------------------------------

#### -via script:

```bash
cd /blockchain/helper
./log_viewer.sh
```

```bash
cd /blockchain/helper
./tmux_logviewer.sh
```
-----------------------------------------------------------------

#### -via single command that follows and shows the last 50 lines of the clients-log:
```bash
docker logs -f --tail=50 execution
docker logs -f --tail=50 beacon
docker logs -f --tail=50 validator
```



## Stopping/Restarting Containers (Do this prior to Shutdowns/Reboots) :

Should you need to alter the original start_###.sh scripts or reboot/shutdown your system, you should! stop/restart the Docker Images that are currently running gracefully. 
Use either `plsmenu`, the stop_docker.sh/ restart_docker.sh script within the /helper folder (default: /blockchain/helper) or a manually command:

#### -via plsmenu

```bash
plsmenu
```
Stop All: `Clients Menu > stop all docker`


Stop Single: `Clients Menu > desired Client > Stop Client`

#### Note: The Shutdown and Reboot options from within plsmenu also provide a gracefull shutdown prior to perform the action.
-----------------------------------------------------------------

#### -via Desktop Icon

if opted to generate the Desktop icons during initial setup, you should find a `stop docker` icon on your Dekstop

-----------------------------------------------------------------

#### -via script:

```bash
cd /blockchain/helper
./stop_docker.sh
./restart_docker.sh
```
-----------------------------------------------------------------

#### -via aio-command:
```bash
docker stop -t 300 $(docker ps -q) && docker -rm $(docker ps -q) && docker container prune -f
```
-----------------------------------------------------------------

#### -via specific command:

```bash
docker stop -t 300 execution && docker -rm execution && docker container prune -f
docker stop -t 180 beacon && docker -rm beacon && docker container prune -f
docker stop -t 180 validator && docker -rm validator && docker container prune -f
```

## Restarting 
After a Reboot the Docker-Images should launch automatically. Check the status with the command: `docker ps`.

Should you need to start them manually use either `plsmenu` or the start_ scripts.

#### -via plsmenu
```bash
plsmenu
```
AIO: `Clients-Menu > Start all Clients`
Client Specific: `Clients-Menu > desired Client > Start desired Client`

-----------------------------------------------------------------

#### -via terminal

```bash
cd /blockchain
./start_execution.sh
./start_consensus.sh
./start_validator.sh
```
-----------------------------------------------------------------

## |#| Modifying flags/options

If you ever find yourself in the need to change/add/remove some option-flags or alter the config you can achieve this by editing the start_###.sh script as you desire. You can use any editor available. Pay attention to end each line with a " \" (space, forward slash) except the last one.

#### -via plsmenu
```bash
plsmenu
```
`Clients Menu > desired Client > Edit Client config > Enter your PW > Apply Changes > Write changes to file with ctrl.+s > Exit editor with ctrl.+x > Restart client via menu`

-----------------------------------------------------------------

#### -via terminal
```bash
cd \blockchain
sudo nano start_execution.sh
```
-----------------------------------------------------------------
## |#| Updating plsmenu and helper files to latest version

### - initial update, if you are running my script prior from prior june 2023 and no version number is shown in plsmenu

![grafik](https://github.com/tdslaine/install_pulse_node/assets/46573429/def99e73-b16d-4939-a0cb-97c471e7e690)

(Old version, no version-number is displayed)


```bash
wget https://raw.githubusercontent.com/tdslaine/install_pulse_node/main/helper/update_files.sh && sudo chmod +x update_files.sh && ./update_files.sh
```
reload plsmenu




### - Updating from within plsmenu, if you are already got a version number displayed in plsmenu

![grafik](https://github.com/tdslaine/install_pulse_node/assets/46573429/ade52126-40fc-420d-95b0-3186d3d9c712)

(Newer version, version-number is displa

```bash
plsmenu
```

`System Menu > Update local helper files`

yed)


## |#| Updating the Nodes Docker-Images

To update your Docker containers/images you can use plsmenu or call the provided `update_docker.sh` script from the /helper folder  (default: /blockchain/helper):

#### -via plsmenu
```bash
plsmenu
```
`Clients-Menu > Update all Clients`

-----------------------------------------------------------------

#### -via script
```bash
cd /blockchain/helper
sudo ./update_docker.sh
```

The script will automatically check for updates and update the necessary containers and images. Review the output of the script to ensure that the update process was successful.

###### Note: that the update_docker script require administrative privileges to execute
-----------------------------------------------------------------

## |#| Reverting to an Older Docker Image Version

In case a recent update to the Geth, Erigon, Lighthouse or Prysm Docker image causes issues, you can follow these steps to revert to a previous, stable version (e.g., v2.0.0):

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


## |#| Prometheus/Grafana Monitoring:

### Setup

:exclamation: If you opted not to run the monitoring setup during the validator setup, follow these steps: :exclamation:

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
:exclamation: If you opted not to allow access from within your local-network to Grafana during the monitoring setup, follow these steps: :exclamation:

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
