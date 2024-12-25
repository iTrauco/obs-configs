# Install SpaceVim
# This command installs SpaceVim and sets it up for Vim by default.
curl -sLf https://spacevim.org/install.sh | bash

# Ensure the SpaceVim configuration file exists
# This creates the initial configuration file for SpaceVim if it doesn't already exist.
mkdir -p ~/.SpaceVim.d
cat << 'EOF' > ~/.SpaceVim.d/init.toml
# SpaceVim Configuration File
[options]
    # Set the default theme for SpaceVim
    colorscheme = "gruvbox"
    # Enable statusline for better visibility
    statusline_separator = "arrow"
    statusline_inactive_separator = "arrow"

[[layers]]
    # Add basic layer support for programming
    name = "lang#python"
    name = "git"
    name = "autocomplete"

[[custom_plugins]]
    # Example of adding a custom plugin
    repo = "scrooloose/nerdtree"
EOF

# Verify SpaceVim installation by launching Vim
vim +SpaceVimUpdate +qall

# Note: Run `vim` to test SpaceVim after completing the installation
echo "SpaceVim installed successfully! Run 'vim' to start."

