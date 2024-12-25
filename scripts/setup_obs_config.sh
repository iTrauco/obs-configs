cat <<'EOF' > ~/obs-config-repo/setup_obs_config.sh
#!/bin/bash

# Paths
OBS_CONFIG_DIR="$HOME/.config/obs-studio"
PROFILE_DIR="$OBS_CONFIG_DIR/basic/profiles/Default"
SCENE_DIR="$OBS_CONFIG_DIR/basic/scenes"
CONFIG_FILE="$PROFILE_DIR/basic.ini"

# Ensure the OBS configuration directories exist
mkdir -p "$PROFILE_DIR"
mkdir -p "$SCENE_DIR"

# Create a basic OBS configuration file with NVENC
cat <<CONFIG > "$CONFIG_FILE"
[General]
Name=Default

[Video]
BaseResolution=1920x1080
OutputResolution=1920x1080
FPS=60

[Output]
StreamingEncoder=nvidia_nvenc_h264
RecordingEncoder=nvidia_nvenc_h264
StreamingBitrate=6000
RecordingFormat=mkv
RecordingQuality=high
CONFIG

echo "OBS configuration written to $CONFIG_FILE"

# Confirm NVENC is available
echo "Checking NVENC support:"
ffmpeg -encoders | grep nvenc
EOF

