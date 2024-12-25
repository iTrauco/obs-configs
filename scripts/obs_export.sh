#!/bin/bash

# Get the project root directory
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
EXPORT_DIR="$PROJECT_ROOT/obs_exports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$PROJECT_ROOT/obs_export.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

create_export_structure() {
    mkdir -p "$EXPORT_DIR/$TIMESTAMP"/{scenes,sources,profiles,config}
    log_message "Created export directory structure at $EXPORT_DIR/$TIMESTAMP"
}

export_scenes() {
    log_message "Exporting scenes..."
    
    # Get list of scenes
    obs-cli scene list > "$EXPORT_DIR/$TIMESTAMP/scenes/scene_list.json"
    
    # Export each scene's details
    while read -r scene; do
        scene_name=$(echo "$scene" | tr -d '"' | tr ' ' '_')
        if [ ! -z "$scene_name" ]; then
            obs-cli scene get "$scene_name" > "$EXPORT_DIR/$TIMESTAMP/scenes/${scene_name}_details.json"
            
            # Export sources for each scene
            obs-cli scene item list "$scene_name" > "$EXPORT_DIR/$TIMESTAMP/scenes/${scene_name}_sources.json"
        fi
    done < <(obs-cli scene list | jq -r '.[]')
}

export_sources() {
    log_message "Exporting source configurations..."
    
    # Export all sources
    obs-cli source list > "$EXPORT_DIR/$TIMESTAMP/sources/source_list.json"
    
    # Export details for each source
    while read -r source; do
        source_name=$(echo "$source" | tr -d '"' | tr ' ' '_')
        if [ ! -z "$source_name" ]; then
            obs-cli source get "$source_name" > "$EXPORT_DIR/$TIMESTAMP/sources/${source_name}_details.json"
            obs-cli source settings "$source_name" > "$EXPORT_DIR/$TIMESTAMP/sources/${source_name}_settings.json"
        fi
    done < <(obs-cli source list | jq -r '.[]')
}

export_profiles() {
    log_message "Exporting profiles and configurations..."
    
    # Copy entire profiles directory
    cp -r "$HOME/.config/obs-studio/basic/profiles" "$EXPORT_DIR/$TIMESTAMP/profiles/"
    
    # Export specific configurations
    cp "$HOME/.config/obs-studio/global.ini" "$EXPORT_DIR/$TIMESTAMP/config/" 2>/dev/null || true
    cp "$HOME/.config/obs-studio/basic.ini" "$EXPORT_DIR/$TIMESTAMP/config/" 2>/dev/null || true
}

create_manifest() {
    log_message "Creating export manifest..."
    
    cat > "$EXPORT_DIR/$TIMESTAMP/manifest.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "obs_version": "$(obs --version 2>/dev/null || echo 'unknown')",
    "system_info": {
        "gpu": "$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader 2>/dev/null || echo 'unknown')",
        "driver": "$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo 'unknown')"
    },
    "export_content": {
        "scenes": "$(ls -1 "$EXPORT_DIR/$TIMESTAMP/scenes" | wc -l)",
        "sources": "$(ls -1 "$EXPORT_DIR/$TIMESTAMP/sources" | wc -l)",
        "profiles": "$(ls -1 "$EXPORT_DIR/$TIMESTAMP/profiles" 2>/dev/null | wc -l)"
    }
}
EOF
}

create_python_template() {
    log_message "Creating Python integration template..."
    
    cat > "$EXPORT_DIR/$TIMESTAMP/novation_integration.py" << EOF
#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path

class OBSNovationController:
    def __init__(self):
        self.scenes_path = Path("${EXPORT_DIR/$TIMESTAMP}/scenes")
        self.sources_path = Path("${EXPORT_DIR/$TIMESTAMP}/sources")
        
    def load_scene_list(self):
        with open(self.scenes_path / "scene_list.json") as f:
            return json.load(f)
    
    def switch_scene(self, scene_name):
        subprocess.run(["obs-cli", "scene", "switch", scene_name])
    
    def toggle_source_visibility(self, scene_name, source_name):
        subprocess.run(["obs-cli", "scene", "item", "visible", scene_name, source_name, "toggle"])
    
    def map_to_novation(self):
        # Add your Novation MIDI mapping logic here
        pass

if __name__ == "__main__":
    controller = OBSNovationController()
    scenes = controller.load_scene_list()
    print(f"Available scenes: {scenes}")
EOF

    chmod +x "$EXPORT_DIR/$TIMESTAMP/novation_integration.py"
}

main() {
    log_message "Starting OBS configuration export..."
    
    create_export_structure
    export_scenes
    export_sources
    export_profiles
    create_manifest
    create_python_template
    
    log_message "Export complete at $EXPORT_DIR/$TIMESTAMP"
}

main