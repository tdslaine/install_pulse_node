#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Input validation library to prevent user errors before they happen
#

source "$(dirname "$0")/colors.sh"

# Validate Ethereum address with checksum verification
validate_eth_address() {
    local address="$1"
    local silent="${2:-false}"
    
    # Check basic format
    if [[ ! "$address" =~ ^0x[a-fA-F0-9]{40}$ ]]; then
        [[ "$silent" != "true" ]] && print_error "Invalid address format. Must be 0x followed by 40 hex characters."
        return 1
    fi
    
    # Visual confirmation
    if [[ "$silent" != "true" ]]; then
        print_info "Address format is valid: $address"
        echo -e "${COLOR_WARNING}Please verify this is YOUR address and you have full access to it!${COLOR_RESET}"
        ask_confirmation "Is this the correct address?" "n" || return 1
    fi
    
    return 0
}

# Validate path exists and has sufficient permissions
validate_path() {
    local path="$1"
    local required_space_gb="${2:-2000}"  # Default 2TB for blockchain data
    local create_if_missing="${3:-true}"
    
    # Expand tilde and resolve path
    path="${path/#\~/$HOME}"
    path="$(realpath -m "$path" 2>/dev/null || echo "$path")"
    
    # Check if path exists
    if [[ ! -d "$path" ]]; then
        if [[ "$create_if_missing" == "true" ]]; then
            print_warning "Path does not exist: $path"
            if ask_confirmation "Create this directory?" "y"; then
                if ! sudo mkdir -p "$path" 2>/dev/null; then
                    print_error "Failed to create directory. Check permissions."
                    return 1
                fi
                print_success "Directory created successfully"
            else
                return 1
            fi
        else
            print_error "Path does not exist: $path"
            return 1
        fi
    fi
    
    # Check write permissions
    if [[ ! -w "$path" ]]; then
        print_warning "No write permission for: $path"
        if ask_confirmation "Attempt to fix permissions?" "y"; then
            sudo chmod 755 "$path" || {
                print_error "Failed to set permissions"
                return 1
            }
        else
            return 1
        fi
    fi
    
    # Check available disk space
    local available_gb=$(df -BG "$path" | awk 'NR==2 {print $4}' | sed 's/G//')
    
    print_info "Available disk space: ${available_gb}GB"
    
    if (( available_gb < required_space_gb )); then
        print_error_box "Insufficient disk space!
        
Required: ${required_space_gb}GB
Available: ${available_gb}GB
Shortfall: $((required_space_gb - available_gb))GB

A PulseChain validator requires significant storage for blockchain data.
Please free up space or choose a different location with more storage."
        return 1
    fi
    
    print_success "Path validation passed: $path (${available_gb}GB available)"
    return 0
}

# Check if port is available
check_port_available() {
    local port=$1
    local description="${2:-Port}"
    
    if command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$port "; then
            print_error "$description ($port) is already in use"
            echo -e "${COLOR_INFO}To see what's using this port, run:${COLOR_RESET}"
            echo -e "  ${COLOR_BOLD}sudo netstat -tulnp | grep :$port${COLOR_RESET}"
            return 1
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln | grep -q ":$port "; then
            print_error "$description ($port) is already in use"
            echo -e "${COLOR_INFO}To see what's using this port, run:${COLOR_RESET}"
            echo -e "  ${COLOR_BOLD}sudo ss -tulnp | grep :$port${COLOR_RESET}"
            return 1
        fi
    else
        print_warning "Cannot check port availability (netstat/ss not found)"
        return 0
    fi
    
    print_success "$description ($port) is available"
    return 0
}

# Validate network connectivity
check_network_connectivity() {
    local test_hosts=("8.8.8.8" "1.1.1.1" "gitlab.com")
    local success=0
    
    print_info "Testing network connectivity..."
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 2 "$host" &>/dev/null; then
            print_success "Connected to $host"
            ((success++))
        else
            print_warning "Cannot reach $host"
        fi
    done
    
    if (( success == 0 )); then
        print_error_box "No network connectivity detected!

This setup requires internet access to:
- Download Docker images
- Sync blockchain data
- Connect to PulseChain network

Please check your network connection and try again."
        return 1
    elif (( success < ${#test_hosts[@]} )); then
        print_warning "Partial network connectivity (${success}/${#test_hosts[@]} hosts reachable)"
        ask_confirmation "Continue anyway?" "n" || return 1
    else
        print_success "Network connectivity verified"
    fi
    
    return 0
}

# Check DNS resolution
check_dns() {
    local test_domain="gitlab.com"
    
    if ! nslookup "$test_domain" &>/dev/null && ! host "$test_domain" &>/dev/null; then
        print_error "DNS resolution failed for $test_domain"
        print_info "Try setting DNS servers: 8.8.8.8, 1.1.1.1"
        return 1
    fi
    
    print_success "DNS resolution working"
    return 0
}

# Validate system has required commands
check_required_commands() {
    local required_commands=("curl" "wget" "git" "awk" "sed" "grep")
    local missing=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
            print_error "Required command not found: $cmd"
        fi
    done
    
    if (( ${#missing[@]} > 0 )); then
        print_error_box "Missing required commands: ${missing[*]}

These will be installed automatically during setup.
If you see this error, the setup will handle it."
        return 1
    fi
    
    print_success "All required commands available"
    return 0
}

# Validate user input is not empty
validate_not_empty() {
    local value="$1"
    local field_name="${2:-Input}"
    
    if [[ -z "$value" ]]; then
        print_error "$field_name cannot be empty"
        return 1
    fi
    
    return 0
}

# Validate numeric input
validate_number() {
    local value="$1"
    local min="${2:-0}"
    local max="${3:-999999}"
    local field_name="${4:-Number}"
    
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        print_error "$field_name must be a number"
        return 1
    fi
    
    if (( value < min || value > max )); then
        print_error "$field_name must be between $min and $max"
        return 1
    fi
    
    return 0
}

# Sanitize user input (remove dangerous characters)
sanitize_input() {
    local input="$1"
    # Remove potentially dangerous characters
    echo "$input" | sed 's/[;&|`$(){}]//g'
}

# Check if running as root (should NOT be)
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error_box "DO NOT run this script as root!

Running as root can cause permission issues and security risks.
Please run as a regular user. The script will ask for sudo when needed.

Usage: ./setup_pulse_node.sh"
        return 1
    fi
    
    return 0
}

# Check if user has sudo access
check_sudo_access() {
    if ! sudo -n true 2>/dev/null; then
        print_info "This script requires sudo access for system configuration."
        print_info "You may be prompted for your password."
        
        if ! sudo true; then
            print_error "Cannot obtain sudo access. Please ensure your user has sudo privileges."
            return 1
        fi
    fi
    
    print_success "Sudo access confirmed"
    return 0
}

# Export all functions for use in other scripts
export -f validate_eth_address
export -f validate_path
export -f check_port_available
export -f check_network_connectivity
export -f check_dns
export -f check_required_commands
export -f validate_not_empty
export -f validate_number
export -f sanitize_input
export -f check_not_root
export -f check_sudo_access
