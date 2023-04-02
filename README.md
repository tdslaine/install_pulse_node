

# Installing and Running Pulse Node with the option to add the lighthouse-validator

This guide will help you install and run the Pulse Node using the provided `setup_pulse_node.sh` script.

## Prerequisites

- A Unix-based operating system (e.g., Ubuntu, Debian)
- Git installed

## Installation Steps

### 1. Install the GitHub client** (if not already installed)

To install the GitHub client on a Unix-based system, you can use the package manager specific to your operating system. For example, on Ubuntu or Debian, you can use the following command:

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

## Updating the Docker-Images should pulse-devs update clients etc.

To update your Docker containers and images using the watchtower.sh script, follow the steps below:

### 1. Make the script executable: 

To make the watchtower.sh script executable, navigate to the directory where the script is located and run the following command:

```bash
   chmod +x watchtower.sh
```

### 2. Run the script: 

To update your Docker containers and images, simply execute the watchtower.sh script by running:

```bash
   ./watchtower.sh
```
### 3. Review the output: 

The script will automatically check for updates and update the necessary containers and images. Review the output of the script to ensure that the update process was successful.

### Please note that the watchtower.sh script might require administrative privileges to execute, depending on your system's settings. If necessary, use sudo to run the script with elevated privileges:

``` bash
   sudo ./watchtower.sh
```

donations accepted so I might be able to work on mainnet too :smiley:

erc20: 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA
