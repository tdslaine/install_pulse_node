#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Key generation safety checks and offline warnings
#

source "$(dirname "$0")/colors.sh"

# Check if system is online
is_online() {
    ping -c 1 -W 2 8.8.8.8 &>/dev/null
    return $?
}

# Show critical offline warning
show_offline_warning() {
    clear
    print_error_box "⚠️  CRITICAL SECURITY WARNING ⚠️

You are about to generate VALIDATOR KEYS while ONLINE!

WHY THIS IS DANGEROUS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Malware could capture your seed phrase
• Network traffic could be monitored
• Keyloggers could record your inputs
• Your keys = Your 32,000,000 PLS at risk!

RECOMMENDED APPROACH:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Use the OFFLINE key generator on an air-gapped machine
2. Generate keys on a clean USB Linux live boot
3. Never connect that machine to internet again
4. Transfer only the keystore files (not seed phrase!)

FOR OFFLINE GENERATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run this on a separate, offline machine:
  ./setup_offline_keygen.sh

Then import the generated keystores here.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo ""
    echo -e "${COLOR_WARNING}${BOX_TL}$(printf '%*s' 60 '' | tr ' ' "${BOX_H}")${BOX_TR}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_V}${COLOR_RESET} ${COLOR_BOLD}Choose your path:${COLOR_RESET}                                      ${COLOR_WARNING}${BOX_V}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_VR}$(printf '%*s' 60 '' | tr ' ' "${BOX_H}")${BOX_VL}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_V}${COLOR_RESET} 1) ${COLOR_ERROR}Continue anyway${COLOR_RESET} (NOT recommended for mainnet!)   ${COLOR_WARNING}${BOX_V}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_V}${COLOR_RESET} 2) ${COLOR_SUCCESS}Disconnect network first${COLOR_RESET} (I'll wait for you)      ${COLOR_WARNING}${BOX_V}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_V}${COLOR_RESET} 3) ${COLOR_INFO}Import keys from offline generation${COLOR_RESET}            ${COLOR_WARNING}${BOX_V}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_V}${COLOR_RESET} 4) ${COLOR_DIM}Exit and use offline keygen${COLOR_RESET}                      ${COLOR_WARNING}${BOX_V}${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_BL}$(printf '%*s' 60 '' | tr ' ' "${BOX_H}")${BOX_BR}${COLOR_RESET}"
    echo ""
}

# Interactive offline warning with choices
handle_online_keygen_warning() {
    local network_choice=""
    
    while true; do
        show_offline_warning
        read -p "Enter your choice (1-4): " network_choice
        
        case $network_choice in
            1)
                # Continue online (dangerous)
                print_warning_box "You chose to continue ONLINE.

This is acceptable for:
  ✓ Testnet validators (practice only)
  ✓ Testing the process
  ✓ Learning how it works

This is DANGEROUS for:
  ✗ Mainnet validators with real PLS
  ✗ Production use
  ✗ Securing real funds"

                if ask_confirmation "Are you ABSOLUTELY SURE you want to generate keys while online?" "n"; then
                    print_warning "Proceeding with online key generation..."
                    return 0  # Continue online
                fi
                ;;
            2)
                # Disconnect network
                print_info "Great choice! Let's disconnect your network."
                echo ""
                print_step 1 3 "Disconnect your network"
                echo "  • Unplug ethernet cable, OR"
                echo "  • Disable WiFi, OR"
                echo "  • Run: sudo nmcli networking off"
                echo ""
                
                if ask_confirmation "Have you disconnected from the network?" "n"; then
                    if is_online; then
                        print_error "System is still online! Please disconnect first."
                        sleep 2
                    else
                        print_success "Network is disconnected. Proceeding safely!"
                        return 0  # Continue offline
                    fi
                fi
                ;;
            3)
                # Import existing keys
                print_info "You'll import keys from offline generation."
                return 2  # Signal to import instead
                ;;
            4)
                # Exit
                print_info "Smart choice! Use ./setup_offline_keygen.sh on an offline machine."
                echo ""
                echo "Steps:"
                echo "  1. Boot a USB Linux live system (Ubuntu/Debian)"
                echo "  2. Run: ./setup_offline_keygen.sh"
                echo "  3. Generate your keys (system will be offline)"
                echo "  4. Save keystores to USB"
                echo "  5. Come back here and import them"
                echo ""
                return 1  # Exit keygen
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, 3, or 4."
                sleep 2
                ;;
        esac
    done
}

# Simplified key generation flow
simplified_keygen_flow() {
    local is_mainnet="$1"
    
    clear
    print_header "VALIDATOR KEY GENERATION" 70
    echo ""
    
    # Check if online
    if is_online; then
        print_warning "⚠️  Network connection detected!"
        echo ""
        
        # Show different warnings for mainnet vs testnet
        if [[ "$is_mainnet" == "true" ]]; then
            print_error_box "MAINNET DETECTED!

For MAINNET validators, generating keys online is EXTREMELY RISKY!
Your 32,000,000 PLS could be stolen.

We STRONGLY recommend offline key generation."
        else
            print_warning_box "TESTNET DETECTED

Since this is testnet (practice), online key generation is acceptable.
However, it's good practice to learn offline generation now!"
        fi
        
        # Handle the warning
        handle_online_keygen_warning
        local result=$?
        
        case $result in
            0)
                # Continue with keygen
                return 0
                ;;
            1)
                # Exit
                return 1
                ;;
            2)
                # Import instead
                return 2
                ;;
        esac
    else
        print_success_box "✓ Network is OFFLINE - Safe to generate keys!

This is the secure way to generate validator keys.
Your seed phrase will never touch the internet."
        
        if ask_confirmation "Proceed with key generation?" "y"; then
            return 0
        else
            return 1
        fi
    fi
}

# Show seed phrase backup instructions
show_seed_phrase_instructions() {
    clear
    print_warning_box "🔐 SEED PHRASE BACKUP INSTRUCTIONS

In the next step, you'll see your 24-word seed phrase.

CRITICAL STEPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. GET PAPER AND PEN READY
   • Use permanent pen (not pencil)
   • Use quality paper (won't fade)
   
2. WRITE DOWN ALL 24 WORDS
   • In exact order
   • Check spelling carefully
   • Number them 1-24

3. VERIFY YOUR WRITING
   • Read it back
   • Check every word
   • Ensure it's legible

4. STORE SAFELY
   • Fireproof safe
   • Safety deposit box
   • Split between locations (advanced)

5. NEVER EVER:
   ✗ Take a photo
   ✗ Type it on computer
   ✗ Store in cloud
   ✗ Email it
   ✗ Share with anyone
   ✗ Store digitally in any way

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

WHY THIS MATTERS:
Anyone with your seed phrase can steal ALL your PLS.
There is NO recovery if you lose it.
This is YOUR responsibility - no one can help you."

    echo ""
    if ! ask_confirmation "I have paper and pen ready, and I understand the importance" "n"; then
        print_error "Please get prepared first. This is critical!"
        return 1
    fi
    
    return 0
}

# Verify user wrote down seed phrase
verify_seed_phrase_backup() {
    clear
    print_header "SEED PHRASE VERIFICATION" 70
    echo ""
    
    print_info "Let's verify you wrote down your seed phrase correctly."
    echo ""
    
    print_warning_box "VERIFICATION CHECKLIST

Please confirm each item:

□ I wrote down all 24 words on paper
□ I numbered them 1-24 in order
□ I double-checked the spelling
□ I can read my handwriting clearly
□ I stored the paper in a safe place
□ I did NOT take a photo or digital copy
□ I understand this is the ONLY backup"

    echo ""
    
    if ! ask_confirmation "I confirm ALL items above" "n"; then
        print_error "Please complete the backup properly before continuing."
        echo ""
        print_info "Your validator will not work without proper key backup!"
        return 1
    fi
    
    print_success_box "✓ Seed phrase backup verified!

Remember: This paper is now worth 32,000,000 PLS.
Treat it like cash. Guard it with your life."
    
    sleep 3
    return 0
}

# Export functions
export -f is_online
export -f show_offline_warning
export -f handle_online_keygen_warning
export -f simplified_keygen_flow
export -f show_seed_phrase_instructions
export -f verify_seed_phrase_backup
