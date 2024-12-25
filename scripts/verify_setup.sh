#!/bin/bash

# Get the project root directory
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$PROJECT_ROOT/verification.log"

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Function to check NVIDIA components
check_nvidia() {
    log_message "Checking NVIDIA components..."
    
    # Check nvidia-settings
    if command -v nvidia-settings &> /dev/null; then
        log_message "✓ nvidia-settings is installed"
        nvidia_version=$(nvidia-settings --version | head -n1)
        log_message "  Version: $nvidia_version"
    else
        log_message "✗ nvidia-settings is NOT installed"
    fi
    
    # Check nvidia-smi
    if command -v nvidia-smi &> /dev/null; then
        log_message "✓ nvidia-smi is available"
        driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
        log_message "  Driver version: $driver_version"
    else
        log_message "✗ nvidia-smi is NOT available"
    fi
}

# Function to check OBS
check_obs() {
    log_message "Checking OBS installation..."
    
    if command -v obs &> /dev/null; then
        log_message "✓ OBS is installed"
        obs_version=$(obs --version 2>/dev/null)
        log_message "  Version: $obs_version"
        
        # Check OBS config directory
        if [ -d "$HOME/.config/obs-studio" ]; then
            log_message "✓ OBS config directory exists"
        else
            log_message "✗ OBS config directory is missing"
        fi
    else
        log_message "✗ OBS is NOT installed"
    fi
}

# Function to check NVENC support
check_nvenc() {
    log_message "Checking NVENC support..."
    
    if command -v ffmpeg &> /dev/null; then
        log_message "✓ FFmpeg is installed"
        nvenc_encoders=$(ffmpeg -encoders 2>/dev/null | grep nvenc)
        if [ -n "$nvenc_encoders" ]; then
            log_message "✓ NVENC encoders available:"
            echo "$nvenc_encoders" | while read -r line; do
                log_message "  $line"
            done
        else
            log_message "✗ No NVENC encoders found"
        fi
    else
        log_message "✗ FFmpeg is NOT installed"
    fi
}

# Function to check system compositor
check_compositor() {
    log_message "Checking system compositor..."
    
    # Check session type
    log_message "Session type: $XDG_SESSION_TYPE"
    
    # List available mutter schemas
    log_message "Available mutter schemas:"
    gsettings list-schemas | grep mutter | while read -r schema; do
        log_message "  $schema"
    done
}

# Main function
main() {
    log_message "Starting verification checks..."
    echo "----------------------------------------"
    
    check_nvidia
    echo "----------------------------------------"
    check_obs
    echo "----------------------------------------"
    check_nvenc
    echo "----------------------------------------"
    check_compositor
    echo "----------------------------------------"
    
    log_message "Verification complete. Check $LOG_FILE for details."
}

# Run main function
main