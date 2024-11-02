#!/bin/bash

# Function to remove existing directories
remove_existing_dirs() {
    for dir in */; do
        config_dir="$HOME/.config/${dir%/}"
        if [ -d "$config_dir" ]; then
            echo "Removing existing directory: $config_dir"
            rm -rf "$config_dir"
        fi
    done
}

# Function to stow dotfiles
stow_dotfiles() {
    for dir in */; do
        stow "${dir%/}"
    done
}

# Function to install Lazygit
install_lazygit() {
    echo "Select your operating system:"
    echo "1) Ubuntu"
    echo "2) Fedora"
    read -rp "Enter the number corresponding to your OS: " os_choice

    case $os_choice in
        1)
            echo "Installing Lazygit on Ubuntu..."
            sudo add-apt-repository ppa:lazygit-team/release
            sudo apt-get update
            sudo apt-get install lazygit
            ;;
        2)
            echo "Installing Lazygit on Fedora..."
            sudo dnf install dnf-plugins-core
            sudo dnf copr enable atim/lazygit -y
            sudo dnf install lazygit
            ;;
        *)
            echo "Invalid selection. Exiting."
            exit 1
            ;;
    esac
}

# Main script execution
remove_existing_dirs
stow_dotfiles
install_lazygit

echo "Setup completed successfully."

