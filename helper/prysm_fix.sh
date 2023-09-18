#!/bin/bash

clear

echo ""
echo "This solution addresses issues faced by users with the v2.2.3 update of Prysm."
echo "It switches the docker images from using the latest tag to the stable v2.2.2 version."
echo ""
echo "Once a subsequent update resolves the problem, you can revert to using the latest tag."
echo ""


# Prompt the user for the installation directory
read -p "Enter install directory [default: /blockchain]: " install_dir

# Set default if user input is empty
install_dir=${install_dir:-/blockchain}

# List of specified files
files=(
    "$install_dir/helper/bls_to_execution.sh"
    "$install_dir/helper/prysm_delete_validator.sh"
    "$install_dir/helper/raw_Commands_WIP.md"
    "$install_dir/helper/setup_validator.sh"
    "$install_dir/helper/prysm_read_accounts.sh"
    "$install_dir/helper/key_mgmt.sh"
    "$install_dir/helper/functions.sh"
    "$install_dir/start_validator.sh"
    "$install_dir/start_consensus.sh"
)

# Replace function
replace_in_files() {
    for file in "${files[@]}"; do
        if [[ -f "$file" ]] && grep -q "$1" "$file"; then
            sed -i "s|$1|$2|g" "$file"
            echo "Replaced in $file"
        fi
    done
}

# Display menu
echo "Choose an option:"
echo "1) Apply fix to use :v2.2.2"
echo "2) Revert back to :latest"
echo ""

# Take user input
read -p "Your choice [1/2]: " choice

case $choice in
    1)
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest" "registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:v2.2.2"
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest" "registry.gitlab.com/pulsechaincom/prysm-pulse/validator:v2.2.2"
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest" "registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:v2.2.2"
        ;;
    
    2)
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:v2.2.2" "registry.gitlab.com/pulsechaincom/prysm-pulse/prysmctl:latest"
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/validator:v2.2.2" "registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest"
        replace_in_files "registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:v2.2.2" "registry.gitlab.com/pulsechaincom/prysm-pulse/beacon-chain:latest"
        ;;
    
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo "Operation completed!"
echo ""
echo "Please restart beacon / validator accordingly"
echo ""
read -p "Press Enter to continue..."
