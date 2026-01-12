#!/bin/bash
# 
# Original PulseChain Validator Setup by tdslaine (Peter L Dipslayer)
# TG: @dipslayer369  Twitter: @dipslayer
# Repository: https://github.com/tdslaine/install_pulse_node
#
# Enhanced by: poseidonPLS
# Enhancements: Color utilities and visual formatting for beginner-friendly output
#

# Color definitions
export COLOR_RESET='\033[0m'
export COLOR_BOLD='\033[1m'
export COLOR_DIM='\033[2m'

# Status colors
export COLOR_SUCCESS='\033[0;32m'      # Green
export COLOR_WARNING='\033[1;33m'      # Yellow
export COLOR_ERROR='\033[0;31m'        # Red
export COLOR_INFO='\033[0;36m'         # Cyan
export COLOR_HIGHLIGHT='\033[1;35m'    # Magenta

# Background colors for important messages
export BG_SUCCESS='\033[42m\033[30m'
export BG_WARNING='\033[43m\033[30m'
export BG_ERROR='\033[41m\033[37m'
export BG_INFO='\033[46m\033[30m'

# Box drawing characters
export BOX_TL='┌'
export BOX_TR='┐'
export BOX_BL='└'
export BOX_BR='┘'
export BOX_H='─'
export BOX_V='│'
export BOX_VR='├'
export BOX_VL='┤'
export BOX_HU='┴'
export BOX_HD='┬'

# Print colored message
print_success() {
    echo -e "${COLOR_SUCCESS}✓ $1${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_ERROR}✗ $1${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_WARNING}⚠ $1${COLOR_RESET}"
}

print_info() {
    echo -e "${COLOR_INFO}ℹ $1${COLOR_RESET}"
}

print_highlight() {
    echo -e "${COLOR_HIGHLIGHT}★ $1${COLOR_RESET}"
}

# Print a header box
print_header() {
    local text="$1"
    local width=${2:-60}
    local padding=$(( (width - ${#text} - 2) / 2 ))
    
    echo -e "\n${COLOR_BOLD}${BOX_TL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_TR}${COLOR_RESET}"
    printf "${COLOR_BOLD}${BOX_V}${COLOR_RESET}%*s${COLOR_HIGHLIGHT}%s${COLOR_RESET}%*s${COLOR_BOLD}${BOX_V}${COLOR_RESET}\n" \
        $padding "" "$text" $padding ""
    echo -e "${COLOR_BOLD}${BOX_BL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_BR}${COLOR_RESET}\n"
}

# Print a section divider
print_divider() {
    local char="${1:-─}"
    local width="${2:-60}"
    echo -e "${COLOR_DIM}$(printf '%*s' $width '' | tr ' ' "$char")${COLOR_RESET}"
}

# Progress bar
# Usage: print_progress 50 100 "Syncing blockchain"
print_progress() {
    local current=$1
    local total=$2
    local label="${3:-Progress}"
    local width=40
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${COLOR_INFO}${label}:${COLOR_RESET} ["
    printf "${COLOR_SUCCESS}%*s${COLOR_RESET}" $filled '' | tr ' ' '█'
    printf "%*s" $empty '' | tr ' ' '░'
    printf "] ${COLOR_BOLD}%3d%%${COLOR_RESET}" $percentage
}

# Spinner animation
# Usage: show_spinner $pid "Loading..."
show_spinner() {
    local pid=$1
    local message="${2:-Working...}"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r${COLOR_INFO}${spin:$i:1} ${message}${COLOR_RESET}"
        sleep 0.1
    done
    printf "\r%*s\r" 80 ""  # Clear the line
}

# Print a step with number
# Usage: print_step 1 5 "Installing dependencies"
print_step() {
    local current=$1
    local total=$2
    local description="$3"
    
    echo -e "\n${COLOR_BOLD}${COLOR_INFO}[Step $current/$total]${COLOR_RESET} ${COLOR_BOLD}$description${COLOR_RESET}"
    print_divider "─" 60
}

# Print an important warning box
print_warning_box() {
    local message="$1"
    local width=60
    
    echo -e "\n${BG_WARNING}"
    echo -e "  ⚠  IMPORTANT WARNING  ⚠  "
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_WARNING}${BOX_TL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_TR}${COLOR_RESET}"
    
    # Word wrap the message
    echo "$message" | fold -s -w $((width - 4)) | while IFS= read -r line; do
        printf "${COLOR_WARNING}${BOX_V}${COLOR_RESET} %-*s ${COLOR_WARNING}${BOX_V}${COLOR_RESET}\n" $((width - 2)) "$line"
    done
    
    echo -e "${COLOR_WARNING}${BOX_BL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_BR}${COLOR_RESET}\n"
}

# Print a success box
print_success_box() {
    local message="$1"
    local width=60
    
    echo -e "\n${BG_SUCCESS}"
    echo -e "  ✓  SUCCESS  ✓  "
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_SUCCESS}${BOX_TL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_TR}${COLOR_RESET}"
    
    echo "$message" | fold -s -w $((width - 4)) | while IFS= read -r line; do
        printf "${COLOR_SUCCESS}${BOX_V}${COLOR_RESET} %-*s ${COLOR_SUCCESS}${BOX_V}${COLOR_RESET}\n" $((width - 2)) "$line"
    done
    
    echo -e "${COLOR_SUCCESS}${BOX_BL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_BR}${COLOR_RESET}\n"
}

# Print an error box
print_error_box() {
    local message="$1"
    local width=60
    
    echo -e "\n${BG_ERROR}"
    echo -e "  ✗  ERROR  ✗  "
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_ERROR}${BOX_TL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_TR}${COLOR_RESET}"
    
    echo "$message" | fold -s -w $((width - 4)) | while IFS= read -r line; do
        printf "${COLOR_ERROR}${BOX_V}${COLOR_RESET} %-*s ${COLOR_ERROR}${BOX_V}${COLOR_RESET}\n" $((width - 2)) "$line"
    done
    
    echo -e "${COLOR_ERROR}${BOX_BL}$(printf '%*s' $width '' | tr ' ' "${BOX_H}")${BOX_BR}${COLOR_RESET}\n"
}

# Ask for confirmation with colored prompt
ask_confirmation() {
    local question="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    echo -e "${COLOR_INFO}${question} ${COLOR_BOLD}${prompt}${COLOR_RESET}"
    read -r response
    
    response=${response:-$default}
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Export all functions for use in other scripts
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_highlight
export -f print_header
export -f print_divider
export -f print_progress
export -f show_spinner
export -f print_step
export -f print_warning_box
export -f print_success_box
export -f print_error_box
export -f ask_confirmation
