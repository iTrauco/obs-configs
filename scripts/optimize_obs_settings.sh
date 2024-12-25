#!/bin/bash

# Get the project root directory
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$PROJECT_ROOT/obs_optimization.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

backup_obs_config() {
    local BACKUP_DIR="$PROJECT_ROOT/backups/obs_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "$HOME/.config/obs-studio" ]; then
        cp -r "$HOME/.config/obs-studio" "$BACKUP_DIR/"
        log_message "Created backup at $BACKUP_DIR"
    fi
}

optimize_nvidia() {
    log_message "Configuring NVIDIA performance settings..."
    
    # Set maximum performance mode
    sudo nvidia-smi -pm 1
    sudo nvidia-smi --auto-boost-default=0
    sudo nvidia-smi -ac 5001,1590
    
    # Configure nvidia-settings
    nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
    log_message "NVIDIA settings configured for maximum performance"
}

configure_obs() {
    local OBS_CONFIG="$HOME/.config/obs-studio"
    mkdir -p "$OBS_CONFIG/basic/profiles/Default"
    
    # Basic OBS configuration
    cat > "$OBS_CONFIG/basic/profiles/Default/basic.ini" << EOF
[General]
Name=Default

[Video]
BaseCX=3840
BaseCY=2160
OutputCX=3840
OutputCY=2160
FPSType=2
FPSCommon=60
ScaleType=bicubic

[Output]
Mode=Advanced

[AdvOut]
Encoder=h264_nvenc
RecEncoder=h264_nvenc
RecType=Standard
RecFormat=mkv
RecFilePath=$HOME/Videos/OBS
RecTracks=1
RecEncoderSettings=rate_control=CQP cqp=18 multipass=qres preset=p4 profile=high lookahead=1 bf=3 spatial-aq=1 temporal-aq=1 rc-lookahead=32

[StreamEncoder]
Encoder=h264_nvenc
Rate_Control=CBR
Bitrate=8000
Preset=p4
Profile=high
Lookahead=true
PsyRd=1.0
BFrames=3
EOF

    log_message "OBS configuration applied"
}

setup_scenes() {
    log_message "Setting up default scenes..."
    
    # Using obs-cli to set up scenes if installed
    if command -v obs-cli &> /dev/null; then
        obs-cli scene add "Main Scene"
        obs-cli scene add "Starting Soon"
        obs-cli scene add "Be Right Back"
        obs-cli scene add "Stream Ending"
    else
        log_message "obs-cli not found - skipping scene setup"
    fi
}

main() {
    log_message "Starting OBS optimization..."
    
    backup_obs_config
    optimize_nvidia
    configure_obs
    setup_scenes
    
    log_message "Optimization complete - please restart OBS Studio"
}

main