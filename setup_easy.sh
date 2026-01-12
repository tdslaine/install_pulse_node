#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Beginner-friendly setup wrapper with guided experience
#
# This is the NEW entry point for beginners. It wraps the original
# setup_pulse_node.sh with additional hand-holding and safety features.
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities
source "${SCRIPT_DIR}/utils/colors.sh"
source "${SCRIPT_DIR}/utils/validators.sh"
source "${SCRIPT_DIR}/utils/preflight.sh"
source "${SCRIPT_DIR}/utils/help.sh"

# Welcome banner
show_welcome() {
    clear
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     🚀 PulseChain Validator Setup - Beginner Edition 🚀      ║
║                                                              ║
║          Making Validator Setup Simple & Safe                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

EOF
    
    echo -e "${COLOR_INFO}Original setup by:${COLOR_RESET} ${COLOR_BOLD}tdslaine (Peter L Dipslayer)${COLOR_RESET}"
    echo -e "${COLOR_DIM}TG: @dipslayer369  Twitter: @dipslayer${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_INFO}Enhanced for beginners by:${COLOR_RESET} ${COLOR_BOLD}poseidonPLS${COLOR_RESET}"
    echo ""
    print_divider "─" 60
    echo ""
}

# Show what will happen
show_overview() {
    cat << 'EOF'

This setup wizard will guide you through installing a PulseChain
validator node. Here's what will happen:

  📋 Step 1: System Check (2 minutes)
     We'll verify your system meets all requirements

  📦 Step 2: Install Dependencies (10-20 minutes)
     Install Docker, tools, and required packages

  ⚙️  Step 3: Configure Clients (5 minutes)
     Choose and configure your execution & consensus clients

  🔑 Step 4: Validator Setup (10 minutes) [Optional]
     Generate keys and set up your validator

  📊 Step 5: Monitoring Setup (5 minutes) [Optional]
     Install Grafana dashboards for monitoring

  ⏱️  TOTAL TIME: ~30-60 minutes (not including blockchain sync)

EOF

    print_info "After installation, your node will start syncing the blockchain."
    print_info "This can take 1-7 days depending on your client choice."
    echo ""
}

# Safety briefing
show_safety_briefing() {
    print_warning_box "IMPORTANT SAFETY INFORMATION

Before we begin, please understand:

1. BACKUP YOUR KEYS
   • Validator keys will be generated during setup
   • Write down your seed phrase on paper
   • Store it in a safe place
   • NEVER share it with anyone

2. WITHDRAWAL ADDRESS
   • You'll set a withdrawal address for rewards
   • This CANNOT be changed later
   • Make absolutely sure you control this wallet
   • Use a hardware wallet if possible

3. SLASHING RISKS
   • Never run the same validator keys on multiple machines
   • Keep your validator online as much as possible
   • Don't modify files unless you know what you're doing

4. SYSTEM REQUIREMENTS
   • Your system must meet minimum requirements
   • Stable internet connection is critical
   • SSD storage is required (HDD won't work)

5. THIS SCRIPT WILL
   • Install software on your system
   • Modify firewall rules
   • Create users and set permissions
   • Download blockchain data (large files)"

    echo ""
    if ! ask_confirmation "I understand the risks and want to continue" "n"; then
        print_info "Setup cancelled. Take your time to learn more before proceeding."
        exit 0
    fi
}

# Main setup flow
main() {
    # Welcome
    show_welcome
    show_overview
    
    if ! ask_confirmation "Ready to begin?" "y"; then
        print_info "Setup cancelled. Run this script again when you're ready!"
        exit 0
    fi
    
    # Safety briefing
    clear
    show_safety_briefing
    
    # Pre-flight checks
    clear
    print_header "SYSTEM REQUIREMENTS CHECK" 70
    echo ""
    print_info "Let's make sure your system is ready..."
    echo ""
    
    if ! run_preflight_checks; then
        print_error_box "System check failed!

Your system doesn't meet the requirements for running a validator.
Please address the issues above and run this setup again.

Need help? Check docs/TROUBLESHOOTING.md or visit:
https://t.me/PulseDEV"
        exit 1
    fi
    
    # All checks passed!
    echo ""
    print_success_box "System check passed! Your system is ready. ✓"
    echo ""
    
    if ! ask_confirmation "Proceed with installation?" "y"; then
        print_info "Setup cancelled."
        exit 0
    fi
    
    # Run the original setup script with enhanced experience
    clear
    print_header "STARTING INSTALLATION" 70
    echo ""
    print_info "Now running the main installation script..."
    print_info "You'll be asked several questions. Type '?' for help on any question."
    echo ""
    sleep 2
    
    # Execute original setup
    cd "${SCRIPT_DIR}"
    
    if [[ -f "setup_pulse_node.sh" ]]; then
        chmod +x setup_pulse_node.sh
        ./setup_pulse_node.sh
    else
        print_error "setup_pulse_node.sh not found!"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        show_general_help
        exit 0
        ;;
    --check-only)
        run_preflight_checks
        exit $?
        ;;
    --version)
        echo "PulseChain Validator Setup - Beginner Edition v1.0"
        echo "Based on original by tdslaine"
        exit 0
        ;;
    *)
        main
        ;;
esac
