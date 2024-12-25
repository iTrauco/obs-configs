# Update and install necessary packages (Zsh, Vim, Git, Curl, Powerline Fonts)
sudo apt update && sudo apt install -y zsh vim git curl fonts-powerline

# Install Oh My Zsh
# This will install and configure Oh My Zsh. It will prompt you to change the default shell.
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install SpaceVim
# This command installs SpaceVim and configures it for Vim.
curl -sLf https://spacevim.org/install.sh | bash

# Install Powerline Fonts
# Clone the Powerline fonts repository and run the installer script.
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts  # Clean up the fonts repository after installation

# Set Zsh as the default shell
# This ensures Zsh is used as the default shell for the current user.
chsh -s $(which zsh)

# Restart the terminal or log out and back in to apply changes
echo "Setup complete. Please restart your terminal or log out and back in to apply the changes."

# Verify that Zsh is the default shell
echo $SHELL  # Should output /usr/bin/zsh if successfully configured

