#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Pre-flight system checks to catch problems BEFORE installation starts
#

source "$(dirname "$0")/colors.sh"
source "$(dirname "$0")/validators.sh"

# System requirements (conservative estimates)
MIN_RAM_GB=16
RECOMMENDED_RAM_GB=32
MIN_DISK_GB=1000
RECOMMENDED_DISK_GB=2000
MIN_CPU_CORES=4
RECOMMENDED_CPU_CORES=8

# Run all pre-flight checks
run_preflight_checks() {
    local errors=0
    local warnings=0
    
    print_header "PRE-FLIGHT SYSTEM CHECK" 70
    
    echo -e "${COLOR_INFO}Checking your system before installation...${COLOR_RESET}"
    echo -e "${COLOR_DIM}This ensures your system meets the requirements for running a PulseChain validator.${COLOR_RESET}\n"
    
    # Check 1: Not running as root
    print_step 1 10 "Checking user permissions"
    if ! check_not_root; then
        ((errors++))
    fi
    
    # Check 2: Sudo access
    print_step 2 10 "Verifying sudo access"
    if ! check_sudo_access; then
        ((errors++))
    fi
    
    # Check 3: OS compatibility
    print_step 3 10 "Checking operating system"
    if ! check_os_compatibility; then
        ((errors++))
    fi
    
    # Check 4: CPU requirements
    print_step 4 10 "Checking CPU"
    if ! check_cpu; then
        ((warnings++))
    fi
    
    # Check 5: RAM requirements
    print_step 5 10 "Checking RAM"
    if ! check_ram; then
        ((warnings++))
    fi
    
    # Check 6: Disk space
    print_step 6 10 "Checking disk space"
    if ! check_disk_space; then
        ((errors++))
    fi
    
    # Check 7: Network connectivity
    print_step 7 10 "Checking network connectivity"
    if ! check_network_connectivity; then
        ((errors++))
    fi
    
    # Check 8: DNS resolution
    print_step 8 10 "Checking DNS"
    if ! check_dns; then
        ((warnings++))
    fi
    
    # Check 9: Required ports
    print_step 9 10 "Checking port availability"
    if ! check_required_ports; then
        ((warnings++))
    fi
    
    # Check 10: Existing installation
    print_step 10 10 "Checking for existing installation"
    if ! check_existing_installation; then
        ((warnings++))
    fi
    
    # Summary
    print_divider "=" 70
    echo ""
    
    if (( errors > 0 )); then
        print_error_box "Pre-flight check FAILED with $errors critical error(s) and $warnings warning(s).

Critical errors must be fixed before continuing.
Please address the issues above and run the setup again."
        return 1
    elif (( warnings > 0 )); then
        print_warning_box "Pre-flight check completed with $warnings warning(s).

Your system meets minimum requirements but has some warnings.
You can continue, but consider addressing the warnings for optimal performance."
        
        if ! ask_confirmation "Continue with installation despite warnings?" "n"; then
            print_info "Installation cancelled. Please address the warnings and try again."
            return 1
        fi
    else
        print_success_box "Pre-flight check PASSED! ✓

Your system meets all requirements for running a PulseChain validator.
You're ready to proceed with the installation."
    fi
    
    return 0
}

# Check OS compatibility
check_os_compatibility() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot determine OS version"
        return 1
    fi
    
    source /etc/os-release
    
    print_info "Detected: $PRETTY_NAME"
    
    # Check if Ubuntu/Debian based
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        print_warning "This script is designed for Ubuntu/Debian. Your OS: $ID"
        print_info "The script may work but hasn't been tested on $PRETTY_NAME"
        return 1
    fi
    
    # Check Ubuntu version
    if [[ "$ID" == "ubuntu" ]]; then
        local version_number="${VERSION_ID%.*}"
        if (( version_number < 20 )); then
            print_error "Ubuntu 20.04 LTS or newer is required. You have: $VERSION_ID"
            return 1
        fi
    fi
    
    print_success "Operating system is compatible"
    return 0
}

# Check CPU
check_cpu() {
    local cpu_cores=$(nproc)
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    
    print_info "CPU: $cpu_model"
    print_info "CPU Cores: $cpu_cores"
    
    if (( cpu_cores < MIN_CPU_CORES )); then
        print_error "Insufficient CPU cores. Minimum: $MIN_CPU_CORES, Found: $cpu_cores"
        return 1
    elif (( cpu_cores < RECOMMENDED_CPU_CORES )); then
        print_warning "CPU cores below recommended. Recommended: $RECOMMENDED_CPU_CORES, Found: $cpu_cores"
        print_info "Your validator will work but may have slower sync times."
        return 1
    fi
    
    print_success "CPU meets requirements"
    return 0
}

# Check RAM
check_ram() {
    local total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    local total_ram_gb=$((total_ram_kb / 1024 / 1024))
    
    print_info "Total RAM: ${total_ram_gb}GB"
    
    if (( total_ram_gb < MIN_RAM_GB )); then
        print_error "Insufficient RAM. Minimum: ${MIN_RAM_GB}GB, Found: ${total_ram_gb}GB"
        print_info "Consider upgrading your system or using a VPS with more RAM."
        return 1
    elif (( total_ram_gb < RECOMMENDED_RAM_GB )); then
        print_warning "RAM below recommended. Recommended: ${RECOMMENDED_RAM_GB}GB, Found: ${total_ram_gb}GB"
        print_info "Your validator will work but may experience memory pressure during sync."
        return 1
    fi
    
    print_success "RAM meets requirements"
    return 0
}

# Check disk space
check_disk_space() {
    local root_available_gb=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    
    print_info "Available disk space on /: ${root_available_gb}GB"
    
    if (( root_available_gb < MIN_DISK_GB )); then
        print_error "Insufficient disk space. Minimum: ${MIN_DISK_GB}GB, Found: ${root_available_gb}GB"
        print_info "PulseChain blockchain data requires significant storage."
        print_info "Consider:"
        print_info "  - Freeing up disk space"
        print_info "  - Adding an external drive"
        print_info "  - Using a VPS with more storage"
        return 1
    elif (( root_available_gb < RECOMMENDED_DISK_GB )); then
        print_warning "Disk space below recommended. Recommended: ${RECOMMENDED_DISK_GB}GB, Found: ${root_available_gb}GB"
        print_info "You may need to expand storage in the future as the blockchain grows."
        return 1
    fi
    
    print_success "Disk space meets requirements"
    return 0
}

# Check required ports
check_required_ports() {
    local ports_to_check=(
        "30303:Execution P2P"
        "9000:Consensus P2P"
        "8545:RPC"
        "5052:Beacon API"
    )
    
    local issues=0
    
    for port_info in "${ports_to_check[@]}"; do
        IFS=':' read -r port description <<< "$port_info"
        if ! check_port_available "$port" "$description"; then
            ((issues++))
        fi
    done
    
    if (( issues > 0 )); then
        print_warning "$issues port(s) are in use. This may indicate an existing installation."
        return 1
    fi
    
    return 0
}

# Check for existing installation
check_existing_installation() {
    local existing_found=false
    
    # Check for Docker containers
    if command -v docker &>/dev/null; then
        if docker ps -a --format '{{.Names}}' | grep -qE '^(execution|beacon|validator)$'; then
            print_warning "Found existing Docker containers (execution/beacon/validator)"
            existing_found=true
        fi
    fi
    
    # Check for common installation paths
    if [[ -d "/blockchain" ]]; then
        print_warning "Found existing /blockchain directory"
        existing_found=true
    fi
    
    if [[ -f "/usr/local/bin/plsmenu" ]]; then
        print_warning "Found existing plsmenu installation"
        existing_found=true
    fi
    
    if $existing_found; then
        print_warning_box "Existing PulseChain installation detected!

This may be:
1. A previous installation that needs to be removed
2. An installation you want to upgrade
3. A conflicting setup

Continuing will modify or replace the existing installation.
Make sure you have backups of any important data!"
        
        return 1
    fi
    
    print_success "No existing installation found"
    return 0
}

# Generate system report
generate_system_report() {
    local report_file="/tmp/pulsechain_system_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "PulseChain Validator System Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        echo "Operating System:"
        cat /etc/os-release
        echo ""
        echo "CPU Information:"
        lscpu
        echo ""
        echo "Memory Information:"
        free -h
        echo ""
        echo "Disk Information:"
        df -h
        echo ""
        echo "Network Interfaces:"
        ip addr
        echo ""
        echo "Docker Status:"
        if command -v docker &>/dev/null; then
            docker --version
            docker ps -a
        else
            echo "Docker not installed"
        fi
    } > "$report_file"
    
    print_success "System report saved to: $report_file"
    echo "$report_file"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_preflight_checks
    exit $?
fi
