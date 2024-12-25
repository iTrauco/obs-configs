#!/bin/bash

# Get the project root directory (where the script is located)
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Output file in project root
OUTPUT_FILE="$PROJECT_ROOT/system_info.txt"

# Collect OS and kernel details
echo "### System Information ###" > $OUTPUT_FILE
uname -a >> $OUTPUT_FILE
cat /etc/os-release >> $OUTPUT_FILE

# Collect CPU details
echo -e "\n### CPU Details ###" >> $OUTPUT_FILE
lscpu >> $OUTPUT_FILE
grep -c ^processor /proc/cpuinfo >> $OUTPUT_FILE

# Collect GPU details and drivers
echo -e "\n### GPU Information ###" >> $OUTPUT_FILE
lspci | grep -E "VGA|3D" >> $OUTPUT_FILE
nvidia-smi 2>/dev/null || echo "NVIDIA driver not installed" >> $OUTPUT_FILE

# Collect memory and storage details
echo -e "\n### Memory and Storage ###" >> $OUTPUT_FILE
free -h >> $OUTPUT_FILE
df -h >> $OUTPUT_FILE
lsblk >> $OUTPUT_FILE

# Check display server and monitor setup
echo -e "\n### Display Server and Monitors ###" >> $OUTPUT_FILE
echo "Display Server: $(echo $XDG_SESSION_TYPE)" >> $OUTPUT_FILE
xrandr --listmonitors >> $OUTPUT_FILE

# Check installed NVIDIA libraries and kernel modules
echo -e "\n### NVIDIA Kernel Modules ###" >> $OUTPUT_FILE
lsmod | grep nvidia >> $OUTPUT_FILE || echo "NVIDIA modules not loaded" >> $OUTPUT_FILE

# Check for OBS and hardware acceleration
echo -e "\n### OBS Studio and Hardware Acceleration ###" >> $OUTPUT_FILE
obs --version 2>/dev/null || echo "OBS not installed" >> $OUTPUT_FILE
ffmpeg -encoders | grep nvenc 2>/dev/null || echo "NVENC not available" >> $OUTPUT_FILE

# Check GNOME version and extensions
echo -e "\n### GNOME Version and Extensions ###" >> $OUTPUT_FILE
gnome-shell --version >> $OUTPUT_FILE
gnome-extensions list >> $OUTPUT_FILE

# Check recent logs for errors
echo -e "\n### System Logs ###" >> $OUTPUT_FILE
journalctl -p 3 -xb | tail -n 20 >> $OUTPUT_FILE

# Final message
echo "System information has been gathered in $OUTPUT_FILE"

# Create a timestamped backup
BACKUP_DIR="$PROJECT_ROOT/backups"
mkdir -p "$BACKUP_DIR"
cp "$OUTPUT_FILE" "$BACKUP_DIR/system_info_$(date +%Y%m%d_%H%M%S).txt"
