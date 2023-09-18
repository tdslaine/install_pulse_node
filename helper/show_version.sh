#!/bin/bash

# OS version
os_version=$(lsb_release -d | cut -f2)

# Kernel version
kernel_version=$(uname -r)

# CPU information
cpu_version=$(grep "model name" /proc/cpuinfo | uniq | cut -d ':' -f2 | sed 's/^ *//')
cores=$(grep -c ^processor /proc/cpuinfo)
threads=$(lscpu | grep 'Thread(s) per core:' | awk '{print $4}')

# RAM information
total_ram=$(free -h | grep Mem | awk '{print $2}')
used_ram=$(free -h | grep Mem | awk '{print $3}')
free_ram=$(free -h | grep Mem | awk '{print $4}')

# Disk information
disk_info=$(df -h / | tail -1 | awk '{print $2 " total, " $3 " used, " $4 " free"}')

# System uptime
uptime_info=$(uptime -p | sed 's/up //')

clear
echo "General System info: "
echo "-------------------------------------------"
echo "OS Version: $os_version"
echo "Kernel Version: $kernel_version"
echo "CPU: $cpu_version"
echo "Cores: $cores"
echo "Threads: $threads"
echo "Total RAM: $total_ram"
echo "Used RAM: $used_ram"
echo "Free RAM: $free_ram"
echo "Disk Info: $disk_info"
echo "System Uptime: $uptime_info"
echo "-------------------------------------------"
echo ""

#Prysm-Beacon
version_string=$(docker exec -it beacon /app/cmd/beacon-chain/beacon-chain --version 2>&1)

if [[ $version_string == *"/"* && $version_string == *" Built at"* ]]; then
    # Extract and display Prysm Beacon info...


# Extract various components from the string
project_name=$(echo $version_string | cut -d '/' -f1)
version_number=$(echo $version_string | cut -d '/' -f2)
commit_hash=$(echo $version_string | cut -d '/' -f3 | cut -d '.' -f1)
build_date=$(echo $version_string | cut -d ':' -f2- | sed 's/ Built at//')

# Display the information in a more friendly format
echo "Prysm Beacon info: "
echo "-------------------------------------------"
#echo "Project Name: $project_name"
echo "Version: $version_number"
echo "Commit Hash: $commit_hash"
echo "Build Date: $build_date"
echo "-------------------------------------------"
echo ""

else
    echo "Prysm Beacon: currently not running"
fi
echo ""

# Prysm-Validator
version_string=$(docker exec -it validator /app/cmd/validator/validator --version 2>&1)

if [[ $version_string == *"/"* && $version_string == *" Built at"* ]]; then
    # Extract and display Prysm Validator info...

# Extract various components from the string
project_name=$(echo $version_string | cut -d '/' -f1)
version_number=$(echo $version_string | cut -d '/' -f2)
commit_hash=$(echo $version_string | cut -d '/' -f3 | cut -d '.' -f1)
build_date=$(echo $version_string | cut -d ':' -f2- | sed 's/ Built at//')

# Display the information in a more friendly format
echo "Prysm Validator info: "
echo "-------------------------------------------"
#echo "Project Name: $project_name"
echo "Version: $version_number"
echo "Commit Hash: $commit_hash"
echo "Build Date: $build_date"
echo "-------------------------------------------"
echo ""
else
    echo "Prysm Validator: currently not running"
fi
echo ""

#Lighthouse
lighthouse_info=$(docker exec -it beacon lighthouse beacon_node --version 2>&1)

# Check if the result contains the expected "lighthouse-beacon_node" pattern
if echo $lighthouse_info | grep -q "lighthouse-beacon_node"; then
    # Extract necessary details from the output
    lighthouse_version=$(echo $lighthouse_info | sed 's/lighthouse-beacon_node //')

    # Display formatted output
echo "Lighthouse Info: "
echo "-------------------------------------------"
echo "Lighthouse Version: $lighthouse_version"
echo "-------------------------------------------"
echo ""

else
    echo "Lighthouse Beacon Node: currently not running"
fi
# GoPls
version_info=$(docker exec -it execution geth version 2>&1)

if [[ $version_info == *"Geth"* && $version_info == *"Version:"* ]]; then
    # Extract and display GoPls info...



# Extract various components from the string
geth=$(echo "$version_info" | grep "Geth")
version=$(echo "$version_info" | grep "Version" | cut -d ':' -f2 | sed 's/^ *//')
commit=$(echo "$version_info" | grep "Git Commit" | cut -d ':' -f2 | sed 's/^ *//')
commit_date=$(echo "$version_info" | grep "Git Commit Date" | cut -d ':' -f2 | sed 's/^ *//')
architecture=$(echo "$version_info" | grep "Architecture" | cut -d ':' -f2 | sed 's/^ *//')
go_version=$(echo "$version_info" | grep "Go Version" | cut -d ':' -f2 | sed 's/^ *//')
os=$(echo "$version_info" | grep "Operating System" | cut -d ':' -f2 | sed 's/^ *//')

# Display the information in a more friendly format
echo "GoPls info: "
echo "-------------------------------------------"
echo "Geth: $geth"
echo "Version: $version"
echo "Git Commit: $commit"
echo "Git Commit Date: $commit_date"
echo "Architecture: $architecture"
echo "Go Version: $go_version"
echo "Operating System: $os"
echo "-------------------------------------------"

else
    echo "GoPls (Geth): currently not running"
fi

echo ""
echo ""
read -p "Press Enter to continue..."
