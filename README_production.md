
# OBS Configuration - Production Branch

This branch contains the OBS configuration files for the **production system**. It includes profiles, scenes, and other settings optimized for high-performance streaming and recording on a desktop workstation.

## Directory Structure
- `profiles/`: Contains OBS profiles for streaming and recording.
- `scenes/`: Contains OBS scene collections.

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd obs-config-repo
   ```

2. Switch to the `production` branch:
   ```bash
   git checkout production
   ```

3. Copy the configuration files to your OBS directory:
   ```bash
   cp -r profiles/ ~/.config/obs-studio/basic/profiles/
   cp -r scenes/ ~/.config/obs-studio/basic/scenes/
   ```

4. Launch OBS:
   ```bash
   obs
   ```

## Notes
- This branch is optimized for a **production desktop system**.
- Any changes to OBS settings should be synced back to this branch:
  ```bash
  git add .
  git commit -m "Update OBS production configuration"
  git push
  ```
