#!/bin/bash

# Prompt for sudo password at the start and keep the session alive
sudo -v
# Refresh sudo session in the background
while true; do
    sudo -v
    sleep 300
done &
SUDO_KEEP_ALIVE_PID=$!

trap 'cleanup_and_exit' INT

function cleanup_and_exit() {
    echo "Interrupted. Cleaning up..."
    start_docker
    kill $SUDO_KEEP_ALIVE_PID
    exit 1
}

#debug helper
#set -x

# Setup variables
DEFAULT_INSTALL_PATH=/blockchain
DATE=$(date +"%Y%m%d%H%M")

function get_main_user() {
    main_user=$(sudo logname || echo $SUDO_USER || echo $USER)
	export main_user
    echo "Main user: $main_user"
}

# Check for pigz installation and install if necessary
if ! command -v pigz &>/dev/null; then
    echo "pigz is not installed. Attempting to install..."
    sudo apt update && sudo apt install tar pigz
fi

# Menu
function menu() {
    clear
    echo ""
    get_main_user
    echo ""
    echo "---------------------------------------"
    echo "| BACKUP and RESTORE for go-pls       |"
    echo "---------------------------------------"
    echo "|                                     |"
    echo "| 1) Backup Chaindata                 |"
    echo "|                                     |"
    echo "| 2) Restore Chaindata                |"
    echo "|                                     |"
    echo "---------------------------------------"

    echo ""
    echo -n "Please enter a choice [1 - 2] "
    read choice

    case $choice in
    1) backup ;;
    2) restore ;;
    *) echo "Invalid option" ;;
    esac
}

# Info Function
function info() {
    echo ""
    echo " Note:"
    echo " ====================================================="
	echo " # If you're planning to store your backup           #"
    echo " # on a USB drive, note the following:               #"
    echo " ====================================================="
    echo " ====================================================="
    echo " USB Mount Points:"
    echo " -----------------------------------------------------"
    echo " /media/$main_user/<drive_label>                  "
    echo " /media/$main_user/<drive_uuid>                   "
    echo " -----------------------------------------------------"
    echo " Replace <drive_label> with the label of your    "
    echo " USB drive. If the drive does not have a label,  "
    echo " it will be its UUID.                            "
    echo " -----------------------------------------------------"
    echo " Ensure your USB drive is formatted with a       "
    echo " filesystem compatible with Linux, such as ext4  "
    echo " or NTFS. Other filesystems might not support    "
    echo " file sizes large enough for the backup.         "
    echo " -----------------------------------------------------"
    echo " Also, confirm the drive has enough space        "
    echo " for your backup.                                "
	echo "------------------------------------------------------"
    echo " If you have enough space on your drive you are  "
	echo " able to create the backup to your local storage "
	echo " too                                             "
	echo " ====================================================="
	echo ""
}

function backup() {
    read -e -p "Please enter your main install path (default: /blockchain): " INSTALL_PATH
    INSTALL_PATH=$(readlink -m "${INSTALL_PATH:-$DEFAULT_INSTALL_PATH}")

    # add folder structure
    CHAINDATA="$INSTALL_PATH/execution/geth/geth/chaindata"
    echo "$CHAINDATA"

    while true; do
        info
        read -e -p "Please enter the target location for your backup (Tab-autocomplete is supported): " BACKUP_LOCATION
        BACKUP_LOCATION=$(readlink -m "${BACKUP_LOCATION%/}")
        if [ -d "$BACKUP_LOCATION" ]; then
            break
        else
            echo "The directory does not exist."
            read -p "Do you want to create it? (y/n)" create_dir
            if [ "$create_dir" != "${create_dir#[Yy]}" ]; then
                sudo mkdir -p "$BACKUP_LOCATION"
                sudo chown $main_user:$main_user "$BACKUP_LOCATION"
                sudo chmod -R 777 "$BACKUP_LOCATION"
            else
                echo "Please enter a valid directory."
            fi
        fi
    done

    read -p "Warning: The Execution-Client will be stopped and resumed after the backup is complete. Do you want to continue? (y/n)" answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        echo ""
        trap sigint_handler_backup INT
        stop_docker
        SIZE=$(du -sb $CHAINDATA | awk '{print $1}')
        FREE_SPACE=$(df -B1 $BACKUP_LOCATION | awk 'NR==2 {print $4}')
        SIZE_GB=$(echo "$SIZE" | awk '{printf "%.2f", $1 / (1024^3)}')
        FREE_SPACE_GB=$(echo "$FREE_SPACE" | awk '{printf "%.2f", $1 / (1024^3)}')
        echo ""

        if ((SIZE < FREE_SPACE)); then
            sudo chmod -R 777 $CHAINDATA
            
            # Summary confirmation
            clear
            echo "===================== Compression ====================="
            echo ""
            echo "Compression provides a trade-off between backup size and backup duration:"
            echo " - With compression, the backup file will have a smaller size, saving storage space."
            echo "   However, the backup process will take longer due to the compression operation."
            echo " - Without compression, the backup process will be faster, resulting in shorter downtime"
            echo "   for the execution client. However, the backup file size will be larger."
            echo ""
            echo "======================================================="

            read -p "Do you want to use compression? (y/N)" use_compression
            use_compression=${use_compression:-N}
            echo ""
            clear
            echo ""
            echo "===================== Backup Summary ====================="
            echo "Source Folder:    $CHAINDATA ($SIZE_GB GB)"
            echo "Target Location:  $BACKUP_LOCATION (Free Space: $FREE_SPACE_GB GB)"
            echo "Compression:      $use_compression"
            echo "=========================================================="
            echo ""
            read -p "Please review the summary above. Do you want to proceed with the backup? (y/n)" confirm
            echo ""

            if [ "$confirm" != "${confirm#[Yy]}" ]; then

                DATE=$(date +"%Y_%m_%d_%H_%M")

                start_time=$(date +"%Y-%m-%d %H:%M:%S")

                # Backup Process
                echo "Started on: $start_time"

                if [ "$use_compression" != "${use_compression#[Yy]}" ]; then
                    # Backup process with compression
                    BACKUP_FILE="$BACKUP_LOCATION/chaindata_$DATE.tar.gz"
                    (tar cfP - -C "$INSTALL_PATH/execution/geth/geth" chaindata | pigz -1 >$BACKUP_FILE) &
                    pid=$!
                else
                    # Backup process without compression
                    BACKUP_FILE="$BACKUP_LOCATION/chaindata_$DATE.tar"
                    (tar cfP - -C "$INSTALL_PATH/execution/geth/geth" chaindata >$BACKUP_FILE) &
                    pid=$!
                fi

                while kill -0 $pid >/dev/null 2>&1; do
                    sleep 1
                    CURRENT_SIZE=$(du -sb $BACKUP_FILE | awk '{print $1}')
                    CURRENT_SIZE_GB=$(echo "$CURRENT_SIZE" | awk '{printf "%.2f", $1 / (1024^3)}')
                    echo -ne "Processed: $CURRENT_SIZE_GB/$SIZE_GB GB\r"
                done
                # End time
                end_time=$(date +"%Y-%m-%d %H:%M:%S")

                # Calculate duration
                duration=$(($(date -d "$end_time" +%s) - $(date -d "$start_time" +%s)))
                hours=$((duration / 3600))
                minutes=$(((duration % 3600) / 60))
                seconds=$((duration % 60))

                sudo chown $main_user:$main_user $BACKUP_FILE
                sudo chmod 777 $BACKUP_FILE

                start_docker
                echo ""
                echo "Backup completed successfully. You can find it in $BACKUP_FILE"
                echo "Start time: $start_time"
                echo "End time: $end_time"
                echo ""
                printf "Duration: %02d:%02d:%02d\n" $hours $minutes $seconds
                echo ""
                echo "Please make sure to unmount/remove your USB-Device safely"
                echo ""
            else
                echo "Backup confirmation declined. Backup aborted."
		start_docker
            fi
        else
            echo "Not enough space to create the backup in the selected location."
	    start_docker
        fi
    else
        echo "Backup aborted."
	start_docker
    fi
}

# Restore Function
function restore() {
    while true; do
        info
        echo ""
        read -e -p "Please enter the full path to your backup file (e.g. /path/to/chaindata_####.tar.gz): " BACKUP_FILE
        echo ""
        if [ -f "$BACKUP_FILE" ]; then
            break
        else
            echo "The file does not exist. Please try again."
        fi
    done
    SIZE=$(du -sb $BACKUP_FILE | awk '{print $1}')
    SIZE_GB=$(echo "$SIZE" | awk '{printf "%.2f", $1 / (1024^3)}')
   DEFAULT_INSTALL_PATH="/blockchain"
	while true; do
		echo ""
		read -e -p "Please enter your main blockchain install path (default: /blockchain): " INSTALL_PATH
		echo ""
		INSTALL_PATH=$(readlink -m "${INSTALL_PATH:-$DEFAULT_INSTALL_PATH}")
		if [ -d "$INSTALL_PATH" ]; then
			echo "The directory exists."
			break
		else
			echo "The directory $INSTALL_PATH does not exist."
			read -p "Would you like to create it? (y/n) " yn
			case $yn in
				[Yy]* ) sudo mkdir -p "$INSTALL_PATH" && sudo chmod -R 777 "$INSTALL_PATH"
						echo "The directory $INSTALL_PATH has been created with permissions set to 777."
						break;;
				[Nn]* ) echo "No directory created. Please specify a valid directory."
						;;
				* ) echo "Please answer yes (y) or no (n).";;
			esac
		fi
	done
	
    
    
	CHAINDATA="$INSTALL_PATH/execution/geth/geth/chaindata"
	            # Check if there is data in the directory
				if [ "$(ls -A $CHAINDATA)" ]; then
					read -p "Directory $CHAINDATA is not empty. Do you want to delete its contents? (y/n)" delete_answer
					if [ "$delete_answer" != "${delete_answer#[Yy]}" ]; then
						stop_docker
						sudo rm -R "$CHAINDATA"
						echo "$CHAINDATA folder has been deleted."
					else
						echo "$CHAINDATA folder has not been deleted."
					fi
				fi
				
	FREE_SPACE=$(df -B1 $INSTALL_PATH | awk 'NR==2 {print $4}')
    if ((SIZE < FREE_SPACE)); then
        trap sigint_handler_restore INT
        stop_docker
         # Check if the target directory exists. If not, create it.
		if [ ! -d "$CHAINDATA" ]; then
				echo "Directory $CHAINDATA does not exist. Creating it..."
				sudo mkdir -p "$CHAINDATA" && sudo chmod -R 777 "$CHAINDATA"
			fi
        start_time=$(date +"%Y-%m-%d %H:%M:%S")
        echo "Started on: $start_time"

            if [[ $BACKUP_FILE == *.tar.gz ]]; then
                # Extraction for compressed backup file
                (pigz -dc "$BACKUP_FILE" | tar xfP - -C "$INSTALL_PATH/execution/geth/geth") &
                pid=$!
            else
                # Extraction for uncompressed backup file
                (tar xf "$BACKUP_FILE" -C "$INSTALL_PATH/execution/geth/geth") &
                pid=$!

            fi

            # Get the size of the CHAINDATA folder
            SIZE_CHAINDATA=$(du -sb $CHAINDATA | awk '{print $1}')
            SIZE_CHAINDATA_GB=$(echo "$SIZE_CHAINDATA" | awk '{printf "%.2f", $1 / (1024^3)}')

            # Get the size of the backup file
            SIZE_BACKUP_FILE=$(du -sb $BACKUP_FILE | awk '{print $1}')
            SIZE_BACKUP_FILE_GB=$(echo "$SIZE_BACKUP_FILE" | awk '{printf "%.2f", $1 / (1024^3)}')

            while kill -0 $pid >/dev/null 2>&1; do
                sleep 1
                CURRENT_SIZE=$(du -sb $CHAINDATA | awk '{print $1}')
                CURRENT_SIZE_GB=$(echo "$CURRENT_SIZE" | awk '{printf "%.2f", $1 / (1024^3)}')
                echo -ne "Processed: $CURRENT_SIZE_GB GB / $SIZE_BACKUP_FILE_GB GB\r"
            done

            start_docker
            end_time=$(date +"%Y-%m-%d %H:%M:%S")

            # Calculate duration
            duration=$(($(date -d "$end_time" +%s) - $(date -d "$start_time" +%s)))
            hours=$((duration / 3600))
            minutes=$(((duration % 3600) / 60))
            seconds=$((duration % 60))

            echo ""
            echo "Restore completed successfully. The data has been restored to $CHAINDATA"
            echo ""
            echo "Start time: $start_time"
            echo "End time: $end_time"
            echo ""
            printf "Duration: %02d:%02d:%02d\n" $hours $minutes $seconds
            echo ""
            echo "Please make sure to unmount/remove your USB-Device safely"
			echo ""

			else
            echo ""
            echo "Restore aborted."
			echo "Not enough space in Target-Folder"
            echo ""
			fi
}

# Docker Controls
function stop_docker() {
    if [ "$(docker ps -q -f name=execution)" ]; then
        echo ""
        read -p "Warning: The Execution-Client (go-pls) is currently running and will be stopped and resumed after the restore is complete. Do you want to continue? (y/n)" answer
        echo ""
        if [ "$answer" != "${answer#[Yy]}" ]; then
            echo ""
            echo ""
            docker stop -t 300 execution >/dev/null 2>&1
            docker container prune -f >/dev/null 2>&1
        fi
    else
        echo "The Execution-Client (go-pls) is currently not running."
    fi
}


function start_docker() {
    echo ""
    echo "Restarting Execution-Client..."
    echo ""
	  sleep 2
    $INSTALL_PATH/start_execution.sh >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Docker start executed successfully."
    else
        echo "Docker start execution failed."
    fi
}

# sigint Controls
function sigint_handler_restore() {
    echo ""
    echo "Canceling restore..."
    echo ""
    sudo chown $main_user:$main_user "$INSTALL_PATH/execution/geth/geth/chaindata"
    sudo chmod -R 777 "$INSTALL_PATH/execution/geth/geth"
    sleep 2
    echo "Restarting Execution Client"
    echo ""
    sleep 2
    start_docker
    exit 0
}

function sigint_handler_backup() {
    echo ""
    echo "Canceling backup..."
    echo ""
    sleep 2
    echo "Deleting incomplete backup-file"
    rm $BACKUP_FILE
    echo "Restarting Execution Client"
    echo ""
    sleep 2
    start_docker
    exit 0
}

# Run the script
menu

# Kill the sudo session refresh process after script execution
kill $SUDO_KEEP_ALIVE_PID
