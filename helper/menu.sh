    VERSION="1.2"
    
    
trap cleanup SIGINT

function cleanup() {
    clear
    echo "Exiting..."
    exit
}

    script_launch() {
        local script_name=$1
        local script_path="${helper_scripts_path}/${script_name}"
        
        if [[ -x ${script_path} ]]; then
            ${script_path}
        else
            echo "Error: ${script_path} not found or not executable."
            exit 1
        fi
    }
helper_scripts_path="/blockchain/helper"
CUSTOM_PATH="/blockchain"

script_launch() {
    echo "Launching script: ${CUSTOM_PATH}/helper/$1"
    ${CUSTOM_PATH}/helper/$1
}

main_menu() {
    while true; do
        main_opt=$(dialog --stdout --title "Main Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                          "Logviewer" "Start different Logviewer" \
                          "Clients Menu" "Execution, Beacon and Validator Clients" \
                          "Validator & Key Setup" "Manage your Validator Keys" \
                          "System" "Update, Reboot, shutodwn, Backup & Restore" \
                          "-" ""\
                          "exit" "Exit the program")

        case $? in
          0)
            case $main_opt in
                "Logviewer")
                    logviewer_submenu
                    ;;
                "Clients Menu")
                    client_actions_submenu
                    ;;
                "Validator & Key Setup")
                    validator_setup_submenu
                    ;;
                "System")
                    system_submenu
                    ;;
                "-")
                    ;;
                "exit")
                    clear
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

logviewer_submenu() {
    while true; do
        lv_opt=$(dialog --stdout --title "Logviewer Menu $VERSION" --stdout --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Tabbed-Terminal Logs" "Multiple Tabs" \
                        "Tmux-Style Logs" "Single Window" \
                        "-" ""\
                        "back" "Back to main menu")

        case $? in
          0)
            case $lv_opt in
                "Tabbed-Terminal Logs")
                    clear && script_launch "log_viewer.sh"
                    ;;
                "Tmux-Style Logs")
                    clear && script_launch "tmux_logviewer.sh"
                    ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

client_actions_submenu() {
    while true; do
        ca_opt=$(dialog --stdout --title "Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Execution-Client Menu" ""\
                        "Beacon-Client Menu" ""\
                        "Validator-Client Menu" ""\
                        "-" ""\
                        "Start all Clients" ""\
                        "Stop all Clients" ""\
                        "Restart all Clients" ""\
                        "Update all Clients" ""\
                        "-" ""\
                        "back" "Back to main menu")

        case $? in
          0)
            case $ca_opt in
                "Execution-Client Menu")
                    execution_submenu
                    ;;
                "Beacon-Client Menu")
                    beacon_submenu
                    ;;
                "Validator-Client Menu")
                    validator_submenu
                    ;;
                "-")
                    ;;
                "Start all Clients")
                    clear
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Stop all Clients")
                    clear && script_launch "stop_docker.sh"
                    ;;
                "Restart all Clients")
                    clear && script_launch "stop_docker.sh"
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Update all Clients")
                    clear && script_launch "update_docker.sh"
                    ${CUSTOM_PATH}/start_execution.sh
                    ${CUSTOM_PATH}/start_consensus.sh
                    ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

execution_submenu() {
    while true; do
        exe_opt=$(dialog --stdout --title "Execution-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Execution-Client" "" \
                        "Stop Execution-Client" "" \
                        "Restart Execution-Client" "" \
                        "-" ""\
                        "Edit Execution-Client Config" "" \
                        "Show Logs" "" \
                        "Update Execution-Client" "" \
                        "-" ""\
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $exe_opt in
                "Start Execution-Client")
                    clear && ${CUSTOM_PATH}/start_execution.sh
                    ;;
                "Stop Execution-Client")
                    clear && sudo docker stop -t 300 execution
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Execution-Client")
                    clear && sudo docker stop -t 300 execution
                    sleep 1
                    sudo docker container prune -f
                    clear && ${CUSTOM_PATH}/start_execution.sh
                    ;;
                 "Edit Execution-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_execution.sh"
                    ;;
                 "Show Logs")
                    clear && sudo docker logs -f execution
                    ;;
                 "Update Execution-Client")
                   clear && docker stop -t 300 execution
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/go-pulse > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/go-erigon > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_execution.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

beacon_submenu() {
    while true; do
        bcn_opt=$(dialog --stdout --title "Beacon-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Beacon-Client" "" \
                        "Stop Beacon-Client" "" \
                        "Restart Beacon-Client" "" \
                        "-" ""\
                        "Edit Beacon-Client Config" "" \
                        "Show Logs" "" \
                        "Update Beacon-Client" "" \
                        "-" ""\
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $bcn_opt in
                "Start Beacon-Client")
                    clear && ${CUSTOM_PATH}/start_consensus.sh
                    ;;
                "Stop Beacon-Client")
                    clear && sudo docker stop -t 180 beacon 
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Beacon-Client")
                    clear && sudo docker stop -t 180 beacon
                    sleep 1
                    sudo docker container prune -f
                    ${CUSTOM_PATH}/start_consensus.sh
                    ;;
                 "Edit Beacon-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_consensus.sh"
                    ;;
                 "Show Logs")
                    clear && sudo docker logs -f beacon
                    ;;
                 "Update Beacon-Client")
                   clear && docker stop -t 180 beacon
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_consensus.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

validator_submenu() {
    while true; do
        val_opt=$(dialog --stdout --title "Validator-Client Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Start Validator-Client" "" \
                        "Stop Validator-Client" "" \
                        "Restart Validator-Client" "" \
                        "-" ""\
                        "Edit Validator-Client Config" "" \
                        "Show Logs" ""\
                        "Update Validator-Client" "" \
                        "-" "" \
                        "back" "Back to Client Actions Menu")

        case $? in
          0)
            case $val_opt in
                "Start Validator-Client")
                    clear && ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Stop Validator-Client")${CUSTOM_PATH}/
                    clear && sudo docker stop -t 180 validator
                    sleep 1
                    sudo docker container prune -f
                    ;;
                "Restart Validator-Client")
                    clear && sudo docker stop -t 180 validator
                    sleep 1
                    sudo docker container prune -f
                    clear && ${CUSTOM_PATH}/start_validator.sh
                    ;;
                "Edit Validator-Client Config")
                    clear && sudo nano "${CUSTOM_PATH}/start_validator.sh"
                    ;;
                "Show Logs")
                    clear && sudo docker logs -f validator
                    ;;
                "Update Validator-Client")
                   clear && docker stop -t 180 validator
                   docker container prune -f && docker image prune -f
                   docker rmi registry.gitlab.com/pulsechaincom/prysm-pulse/validator > /dev/null 2>&1
                   docker rmi registry.gitlab.com/pulsechaincom/lighthouse-pulse > /dev/null 2>&1
                   ${CUSTOM_PATH}/start_validator.sh
                   ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}


validator_setup_submenu() {
    while true; do
        options=("Key Management" "Generate, Add, Import or Restore Validator-Keys" \
                 "-" "" \
                 "Convert BLS-Keys" "00-BLS to 01-Execution Wallet conversion" \
                 "Exit your Validator(s)" "Initiate the Exit of your Validator(s)" \
                 "-" "" \
                 "GoPLS - BlockMonitor" "Compare local Block# with scan.puslechain.com" \
                 "GoPLS - Database Prunning" "Prune your local DB to freeup space" \
                 "-" "" \
                 "Prysm - List Accounts" "List all Accounts from the Validator DB" \
                 "Prysm - Delete Validator" "Delete/Remove Accounts from Validator" \
                 "-" "" \
                 "Validator Info per indice" "Backup, should beacon.pulsechain.com be down"\
                 "-" ""
                 "ReRun Initial Setup" "" \
                 "-" ""\
                 "back" "Back to main menu; Return to the main menu.")
        vs_opt=$(dialog --stdout --title "Node/Validator Setup Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 "${options[@]}")
        case $? in
            0)
                case $vs_opt in
                    "Key Management")
                        clear && script_launch "key_mgmt.sh"
                        ;;
                    "-")
                        ;;
                    "Convert BLS-Keys")
                        clear && script_launch "bls_to_execution.sh"
                        ;;
                    "Exit your Validator(s)")
                        clear && script_launch "exit_validator.sh"
                        ;;
                    "-")
                        ;;
                    "GoPLS - BlockMonitor")
                        clear && script_launch "compare_blocks.sh"
                        ;;
                    "GoPLS - Database Prunning")
                        tmux new-session -s prune $CUSTOM_PATH/helper/gopls_prune.sh
                        ;;
                    "-")
                        ;;                        
                    "Prysm - List Accounts")
                        clear && script_launch "prysm_read_accounts.sh"
                        ;;
                    "Prysm - Delete Validator")
                        clear && script_launch "prysm_delete_validator.sh"
                        ;;
                    "-")
                        ;;
                    "Validator Info per indice")
                        clear && script_launch "status_batch.sh"
                        ;;
                    "-")
                        ;;                    
                    "ReRun Initial Setup")
                        clear && script_launch "setup_validator.sh"
                        ;;
                    "back")
                        break
                        ;;
                esac
                ;;
            1)
                break
                ;;
        esac
    done
}


system_submenu() {
    while true; do
        sys_opt=$(dialog --stdout --title "System Menu $VERSION" --backtitle "created by DipSlayer 0xCB00d822323B6f38d13A1f951d7e31D9dfDED4AA" --menu "Choose an option:" 0 0 0 \
                        "Update Local Helper-Files" "Get latest additions/changes for plsmenu" \
                        "Add Graceful-Shutdown to System" "Triggered for system shutdown/reboot" \ 
                        "-" "" \
                        "Update & Reboot System" "" \
                        "Reboot System" "" \
                        "Shutdown System" "" \
                        "-" "" \
                        "Backup and Restore" "Chaindata for go-pulse" \
                        "-" "" \
                        "back" "Back to main menu")

        case $? in
          0)
            case $sys_opt in
                "Update Local Helper-Files")
                    clear && script_launch "update_files.sh"
                    ;;
                "Add Graceful-Shutdown to System")
                    clear && script_launch "grace.sh"
                    ;;                    
                "-")
                    ;;                    
                "Update & Reboot System")
                    clear
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"
                    sleep 3
                    clear
                    echo "Getting System updates..."
                    sudo apt update && sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y
                    read -p "Update done, reboot now? Press enter to continue or Ctrl+C to cancel."
                    sleep 5
                    sudo reboot now
                    ;;
                "Reboot System")
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"  
                    sleep 3
                    read -p "Reboot now? Press enter to continue or Ctrl+C to cancel."
                    sudo reboot now
                    ;;
                "Shutdown System")
                    echo "Stopping running docker container..."
                    script_launch "stop_docker.sh"  
                    sleep 3
                    read -p "Shutdown now? Press enter to continue or Ctrl+C to cancel."                    
                    sudo shutdown now
                    ;;

                "-")
                    ;;
                "Backup and Restore")
                    if tmux has-session -t bandr 2>/dev/null; then
                    # If the session exists, attach to it
                    tmux attach-session -t bandr
                    else
                    # If the session does not exist, create and attach to it
                    tmux new-session -d -s bandr $CUSTOM_PATH/helper/backup_restore.sh
                    tmux attach-session -t bandr
                    fi
                    ;;
                "-")
                    ;;
                "back")
                    break
                    ;;
            esac
            ;;
          1)
            break
            ;;
        esac
    done
}

main_menu
