#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Contextual help system with beginner-friendly explanations
#

source "$(dirname "$0")/colors.sh"

# Show help for network selection
help_network_selection() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What's the difference between Mainnet and Testnet?       │
└─────────────────────────────────────────────────────────────┘

MAINNET (Production Network)
  • This is the REAL PulseChain network
  • Uses real PLS tokens with real value
  • Your validator will earn real rewards
  • Requires 32,000,000 PLS to activate
  • Choose this if you're ready to run a production validator

TESTNET (Test Network)  
  • This is a testing environment
  • Uses test PLS tokens (no real value)
  • Perfect for learning and practicing
  • Free test tokens available from faucets
  • Choose this if you're new and want to practice first

💡 RECOMMENDATION FOR BEGINNERS:
   Start with TESTNET to learn the process without risk!
   Once comfortable, you can set up a MAINNET validator.

EOF
    press_enter_to_continue
}

# Show help for execution client selection
help_execution_client() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What is an Execution Client?                             │
└─────────────────────────────────────────────────────────────┘

The execution client processes transactions and maintains the
blockchain state. Think of it as the "engine" of your node.

GETH (Recommended for most users)
  ✓ Faster initial sync (days instead of weeks)
  ✓ Lower disk space usage
  ✓ Proven stability and reliability
  ✓ Best for normal validator operation
  ✗ Doesn't store full historical data

ERIGON (For advanced users)
  ✓ Stores complete blockchain history
  ✓ Useful for developers and block explorers
  ✓ More detailed data access
  ✗ Much longer sync time (weeks)
  ✗ Requires more disk space (3TB+)

💡 RECOMMENDATION FOR BEGINNERS:
   Choose GETH unless you specifically need historical data.
   You can always switch later if needed.

EOF
    press_enter_to_continue
}

# Show help for consensus client selection
help_consensus_client() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What is a Consensus Client?                              │
└─────────────────────────────────────────────────────────────┘

The consensus client handles validator duties and network
consensus. It works together with your execution client.

LIGHTHOUSE
  ✓ Written in Rust (memory safe)
  ✓ Excellent performance
  ✓ Lower resource usage
  ✓ Great documentation
  ✓ Popular choice in the community

PRYSM
  ✓ Written in Go
  ✓ Feature-rich
  ✓ Good performance
  ✓ Strong development team

💡 RECOMMENDATION FOR BEGINNERS:
   Both are excellent choices! Lighthouse is slightly more
   popular and has lower resource usage. Pick either one.

🔒 SECURITY TIP:
   Client diversity is important for network health. Check
   what others are running and consider choosing the minority
   client to help decentralization.

EOF
    press_enter_to_continue
}

# Show help for installation path
help_installation_path() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 Where should I install the blockchain data?              │
└─────────────────────────────────────────────────────────────┘

This is where all your blockchain data will be stored.

REQUIREMENTS:
  • At least 2TB of free space (blockchain grows over time)
  • Fast SSD storage (HDD will be too slow)
  • Reliable drive (you don't want data corruption)

COMMON CHOICES:
  • /blockchain (default, simple and clean)
  • /mnt/blockchain (if using a separate mounted drive)
  • /home/username/blockchain (if you have space in home)

💡 RECOMMENDATION:
   Use the default /blockchain unless you have a specific
   reason to change it. Make sure it's on an SSD!

⚠️  IMPORTANT:
   Once you start syncing, moving this data is difficult.
   Choose wisely!

EOF
    press_enter_to_continue
}

# Show help for withdrawal address
help_withdrawal_address() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What is a Withdrawal Address?                            │
└─────────────────────────────────────────────────────────────┘

This is YOUR wallet address where:
  • Validator rewards will be sent
  • Your staked PLS will be returned when you exit

🔒 CRITICAL SECURITY INFORMATION:

  1. You MUST have full control of this wallet
     • Use a hardware wallet (Ledger, Trezor) - RECOMMENDED
     • Or a wallet where you control the private keys
     • NEVER use an exchange address!

  2. This address CANNOT be changed later
     • Double-check before confirming
     • Triple-check the address is correct
     • One mistake = permanent loss of funds

  3. Use the checksummed format
     • Copy from block explorer (scan.pulsechain.com)
     • Has mixed upper/lowercase letters
     • Example: 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B

💡 BEST PRACTICE:
   1. Generate address on hardware wallet
   2. Copy from block explorer to ensure checksum
   3. Paste here
   4. Verify it matches your wallet exactly
   5. Write it down on paper as backup

⚠️  WARNING:
   If you lose access to this wallet, you lose your validator
   rewards and staked PLS forever. There is NO recovery!

EOF
    press_enter_to_continue
}

# Show help for fee recipient
help_fee_recipient() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What is a Fee Recipient Address?                         │
└─────────────────────────────────────────────────────────────┘

This is where transaction fees (tips) from blocks you propose
will be sent. This is separate from your staking rewards.

DIFFERENCE FROM WITHDRAWAL ADDRESS:
  • Withdrawal Address: Gets staking rewards + your stake back
  • Fee Recipient: Gets transaction fees from proposed blocks

💡 RECOMMENDATION:
   Use the SAME address as your withdrawal address for
   simplicity. This way all your earnings go to one place.

🔒 SECURITY:
   Same rules apply - must be an address you fully control!

EOF
    press_enter_to_continue
}

# Show help for graffiti
# Show help for key generation method
help_keygen_method() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 How should I generate my validator keys?                 │
└─────────────────────────────────────────────────────────────┘

You have three options for key generation:

1. GENERATE NEW KEYS (Fresh Start)
   • Creates brand new validator keys
   • Gives you a new 24-word seed phrase
   • Use this for your first validator
   
   ⚠️  SECURITY: Best done OFFLINE on air-gapped machine!

2. IMPORT KEYS FROM OFFLINE GENERATION (Most Secure)
   • You generated keys on an offline machine
   • Now importing the keystore files
   • Seed phrase never touched the internet
   
   ✓ RECOMMENDED for mainnet with real PLS!

3. RESTORE FROM SEED PHRASE (Recovery)
   • You already have a seed phrase
   • Recreating keys from it
   • Use this to restore lost keys
   
   ⚠️  SECURITY: Only enter seed phrase on trusted, offline machine!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔒 SECURITY BEST PRACTICE:

For MAINNET (real PLS):
  1. Use a separate, offline machine
  2. Boot from USB Linux live system
  3. Run: ./setup_offline_keygen.sh
  4. Generate keys (machine stays offline forever)
  5. Save keystores to USB
  6. Import keystores on your validator

For TESTNET (practice):
  • Online generation is acceptable
  • Good opportunity to practice the process
  • No real funds at risk

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 WHY OFFLINE MATTERS:

Your seed phrase = Full control of 32,000,000 PLS
  • Malware could steal it
  • Keyloggers could record it
  • Network traffic could leak it
  
Offline generation = Seed phrase never touches internet = Safe!

EOF
    press_enter_to_continue
}

# Show help for SSH access
help_ssh_access() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 Should I allow SSH access?                               │
└─────────────────────────────────────────────────────────────┘

SSH (Secure Shell) lets you connect to your server remotely
through a terminal. Think of it as remote desktop for command line.

WHEN TO SAY YES:
  ✓ Running on a VPS (DigitalOcean, Contabo, etc.)
  ✓ Running on a server in another room/location
  ✓ Need to manage the server remotely
  ✓ Don't have physical access to the machine

WHEN TO SAY NO:
  ✗ Running on your desktop/laptop right in front of you
  ✗ Only accessing it locally
  ✗ Don't need remote access

🔒 SECURITY DETAILS:
  • SSH will be restricted to your local network only
  • Not exposed to the internet (safe from attacks)
  • You can change this later if needed

💡 RECOMMENDATION:
  If you're running on a VPS or remote server: SAY YES
  If you're running on your local machine: SAY NO
  
  When in doubt, say YES - you can always disable it later.

EOF
    press_enter_to_continue
}

# Show help for RPC access
help_rpc_access() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 Should I allow RPC access?                               │
└─────────────────────────────────────────────────────────────┘

RPC (Remote Procedure Call) lets other applications query your
node for blockchain data. It's like an API for your node.

WHEN TO SAY YES:
  ✓ You want to connect MetaMask/wallets to your node
  ✓ You're a developer testing dApps
  ✓ You need to query blockchain data programmatically
  ✓ Running a block explorer or analytics

WHEN TO SAY NO:
  ✗ Just running a validator (most people!)
  ✗ Don't need to query blockchain data
  ✗ Not connecting any wallets or apps to it

🔒 SECURITY DETAILS:
  • RPC will ONLY be accessible from:
    - Localhost (127.0.0.1)
    - Your local network (192.168.x.x)
  • NEVER exposed to the internet
  • Safe from external attacks

⚠️  IMPORTANT:
  Validators don't need RPC access to function!
  Your validator will work perfectly fine without it.

💡 RECOMMENDATION FOR BEGINNERS:
  SAY NO unless you specifically know you need it.
  You can always enable it later if you need it.

EXAMPLE USE CASES:
  • "I want to use my node with MetaMask" → YES
  • "I'm just validating" → NO
  • "I'm building a dApp" → YES
  • "I don't know what RPC is" → NO (safe default)

EOF
    press_enter_to_continue
}

help_graffiti() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 🤔 What is Graffiti?                                        │
└─────────────────────────────────────────────────────────────┘

Graffiti is a custom message that gets included in blocks
you propose. It's like your validator's signature!

EXAMPLES:
  • "PulseChain Validator"
  • "Built with ❤️"
  • Your Twitter handle
  • Your validator name

LIMITATIONS:
  • Maximum 32 characters
  • Publicly visible on block explorers
  • Can be changed later if you want

💡 FUN FACT:
   You can see other validators' graffiti on block explorers.
   Some validators use it for messages, jokes, or branding!

This is optional and purely cosmetic - it doesn't affect
your validator's performance or rewards.

EOF
    press_enter_to_continue
}

# Show general help
show_general_help() {
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────┐
│ 📚 PulseChain Validator Setup - Quick Help                  │
└─────────────────────────────────────────────────────────────┘

WHAT THIS SCRIPT DOES:
  1. Checks your system meets requirements
  2. Installs Docker and dependencies
  3. Sets up execution client (Geth/Erigon)
  4. Sets up consensus client (Lighthouse/Prysm)
  5. Optionally sets up validator
  6. Configures monitoring (Grafana/Prometheus)

TIME REQUIRED:
  • Installation: 30-60 minutes
  • Blockchain sync: 1-7 days (depends on client choice)

WHAT YOU NEED:
  • Ubuntu 20.04+ or Debian-based Linux
  • 32GB+ RAM (16GB minimum)
  • 2TB+ SSD storage
  • Stable internet connection
  • 32,000,000 PLS (for mainnet validator)

GETTING HELP:
  • Press '?' during prompts for context-specific help
  • Check docs/ folder for detailed guides
  • Visit PulseDEV Telegram: https://t.me/PulseDEV
  • Read the README.md file

SAFETY FEATURES:
  ✓ Pre-flight checks catch problems before starting
  ✓ Input validation prevents mistakes
  ✓ Automatic backups before major changes
  ✓ Rollback capability if something fails

EOF
    press_enter_to_continue
}

# Helper function for press enter
press_enter_to_continue() {
    echo ""
    echo -e "${COLOR_INFO}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Show help based on context
show_contextual_help() {
    local context="$1"
    
    case "$context" in
        "network")
            help_network_selection
            ;;
        "execution")
            help_execution_client
            ;;
        "consensus")
            help_consensus_client
            ;;
        "path")
            help_installation_path
            ;;
        "withdrawal")
            help_withdrawal_address
            ;;
        "fee")
            help_fee_recipient
            ;;
        "graffiti")
            help_graffiti
            ;;
        "ssh")
            help_ssh_access
            ;;
        "rpc")
            help_rpc_access
            ;;
        "keygen")
            help_keygen_method
            ;;
        "general"|*)
            show_general_help
            ;;
    esac
}

# Export functions
export -f help_network_selection
export -f help_execution_client
export -f help_consensus_client
export -f help_installation_path
export -f help_withdrawal_address
export -f help_fee_recipient
export -f help_graffiti
export -f help_ssh_access
export -f help_rpc_access
export -f help_keygen_method
export -f show_general_help
export -f show_contextual_help
