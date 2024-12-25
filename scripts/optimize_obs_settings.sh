#!/bin/bash

# Output file where results will be saved
log_file="obs_settings_optimization.log"

# Function to detect CPU
detect_cpu() {
    cpu_info=$(lscpu)
    echo "CPU Info: $cpu_info" | tee -a "$log_file"
    # Extract number of cores
    cpu_cores=$(nproc)
    if [ "$cpu_cores" -gt 8 ]; then
        echo "High-end CPU detected (more than 8 cores)." | tee -a "$log_file"
        encoder="x264"
        cpu_priority="veryfast"  # For higher quality and lower CPU usage
    else
        echo "Low-end CPU detected (8 or fewer cores)." | tee -a "$log_file"
        encoder="nvenc"  # Use NVENC for hardware encoding
        cpu_priority="fast"  # Better to reduce CPU load
    fi
}

# Function to detect GPU (specifically for NVIDIA)
detect_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        gpu_info=$(nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader,nounits)
        echo "GPU Info: $gpu_info" | tee -a "$log_file"
        gpu_memory_total=$(echo $gpu_info | cut -d ',' -f 2 | tr -d '[:space:]')
        
        if [ "$gpu_memory_total" -gt 4000 ]; then
            echo "High GPU memory detected (4GB or more). Using NVENC." | tee -a "$log_file"
            encoder="nvenc"
        else
            echo "Low GPU memory detected (less than 4GB)." | tee -a "$log_file"
            encoder="x264"
        fi
    else
        echo "No NVIDIA GPU detected. Falling back to x264 encoding." | tee -a "$log_file"
        encoder="x264"
    fi
}

# Function to detect RAM
detect_ram() {
    ram_info=$(free -h | grep Mem)
    ram_total=$(echo $ram_info | awk '{print $2}')
    echo "Total RAM: $ram_total" | tee -a "$log_file"

    # Remove unit (Gi or Mi) and convert to integer value for comparison
    ram_value=$(echo $ram_total | sed 's/[A-Za-z]//g')  # Remove any alphabetic characters
    if [ "$ram_value" -ge 16000 ]; then  # 16GB or more
        echo "Sufficient RAM for high settings." | tee -a "$log_file"
        ram_priority="high"
    else
        echo "Low RAM detected. Lowering some OBS settings." | tee -a "$log_file"
        ram_priority="low"
    fi
}

# Function to set OBS settings based on hardware
set_obs_settings() {
    echo "Setting OBS encoding to $encoder with CPU priority $cpu_priority." | tee -a "$log_file"
    # Make sure obs-cli is connected properly
    if ! command -v obs-cli &> /dev/null; then
        echo "obs-cli not found. Please install it." | tee -a "$log_file"
        exit 1
    fi

    # Use obs-cli without --host and --port options
    obs-cli setting set "VideoBitrate" 6000 2>&1 | tee -a "$log_file"  # High bitrate for good networks
    obs-cli setting set "Encoder" "$encoder" 2>&1 | tee -a "$log_file"
    obs-cli setting set "CPUUsagePreset" "$cpu_priority" 2>&1 | tee -a "$log_file"
    
    if [ "$ram_priority" == "low" ]; then
        obs-cli setting set "BaseResolution" 1280x720 2>&1 | tee -a "$log_file"
        obs-cli setting set "OutputResolution" 1280x720 2>&1 | tee -a "$log_file"
    else
        obs-cli setting set "BaseResolution" 1920x1080 2>&1 | tee -a "$log_file"
        obs-cli setting set "OutputResolution" 1920x1080 2>&1 | tee -a "$log_file"
    fi
}

# Detect system hardware
echo "Optimizing OBS settings based on your hardware..." | tee -a "$log_file"
detect_cpu
detect_gpu
detect_ram

# Set OBS settings based on hardware
set_obs_settings

echo "OBS settings have been optimized based on your hardware." | tee -a "$log_file"
