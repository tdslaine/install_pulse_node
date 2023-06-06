#!/bin/bash

#Exit Validator

start_dir=$(pwd)
script_dir=$(dirname "$0")

source "$script_dir/functions.sh"

tab_autocomplete
check_and_set_network_variables

function get_user_choices() {
    echo "-----------------------------------------"
    echo "       Choose your Validator Client      "
    echo "-----------------------------------------"
    echo "(based on your consensus/beacon Client)"
    echo ""
    echo "---------------------------------------"
    echo "1. Lighthouse - single key exit"
    echo "2. Lighthouse -multiple keys exit"
    echo "---------------------------------------"
    echo "3. Prysm - single or multiple key exit"
    echo ""
    echo ""
    echo "0. Return or Exit"
    echo ""
    read -p "Enter your choice (1, 2 or 0): " client_choice

    # Validate user input for client choice
    while [[ ! "$client_choice" =~ ^[0-3]$ ]]; do
        echo "Invalid input. Please enter a valid choice (1, 2, 3 or 0): "
        read -p "Enter your choice (1, 2, 3 or 0): " client_choice
    done

    if [[ "$client_choice" == "0" ]]; then
        echo "Exiting..."
        exit 0
    fi

    echo "${client_choice}"
}

get_user_choices
#client_choice=$(get_user_choices)

get_main_user

if [[ "$client_choice" == "1" ]]; then  # lighthouse
    get_install_path
    while true; do
        start_script "../start_validator" > /dev/null 2>&1
        exit_validator_LH
        stop_docker_container "exit_validator" > /dev/null 2>&1
        sudo docker container prune -f > /dev/null 2>&1
        press_enter_to_continue
        read -p "Would you like to exit another Validator? (y/n): " user_input
        if [[ "${user_input,,}" == "n" ]]; then
            break
        fi
    done
    exit 0
    
elif [[ "$client_choice" == "2" ]]; then  # Lighthouse Multi-Key Exit
    start_script "lh_batch_exit.sh"
    exit 0
fi

elif [[ "$client_choice" == "3" ]]; then  # PRYSM
    get_install_path
    start_script "../start_validator" > /dev/null 2>&1
    exit_validator_PR
    stop_docker_container "exit_validator" > /dev/null 2>&1
    sudo docker container prune -f > /dev/null 2>&1
    sudo docker restart validator
    press_enter_to_continue
    exit 0
fi
