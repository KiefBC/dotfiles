#!/bin/bash

# Function to detect the operating system
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            ubuntu)
                os="ubuntu"
                ;;
            fedora)
                os="fedora"
                ;;
            *)
                echo "Unsupported operating system: $ID"
                exit 1
                ;;
        esac
    else
        echo "Cannot determine operating system."
        exit 1
    fi
}

# Function to install a package if not already installed
install_package() {
    local package=$1
    if ! command -v $package &> /dev/null; then
        echo "Installing $package..."
        case $os in
            ubuntu)
                sudo apt-get update
                sudo apt-get install -y $package
                ;;
            fedora)
                sudo dnf install -y $package
                ;;
        esac
    else
        echo "$package is already installed."
    fi
}

# Function to install Lazygit
install_lazygit() {
    if ! command -v lazygit &> /dev/null; then
        echo "Installing Lazygit..."
        case $os in
            ubuntu)
                sudo add-apt-repository ppa:lazygit-team/release -y
                sudo apt-get update
                sudo apt-get install -y lazygit
                ;;
            fedora)
                sudo dnf install -y dnf-plugins-core
                sudo dnf copr enable atim/lazygit -y
                sudo dnf install -y lazygit
                ;;
        esac
    else
        echo "Lazygit is already installed."
    fi
}

# Function to install Neovim
install_neovim() {
    if ! command -v nvim &> /dev/null; then
        echo "Installing Neovim..."
        case $os in
            ubuntu)
                if ! command -v snap &> /dev/null; then
                    echo "Snap is not installed. Installing Snap..."
                    sudo apt-get update
                    sudo apt-get install -y snapd
                fi
                sudo snap install nvim --classic
                ;;
            fedora)
                sudo dnf install -y neovim
                ;;
        esac
    else
        echo "Neovim is already installed."
    fi
}

# Function to install Helix
install_helix() {
    install_package "helix"
}

# Function to install WezTerm
install_wezterm() {
    if ! command -v wezterm &> /dev/null; then
        echo "Installing WezTerm..."
        case $os in
            ubuntu)
                # Add the GPG key
                curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-archive-keyring.gpg
                # Add the repository
                echo "deb [signed-by=/usr/share/keyrings/wezterm-archive-keyring.gpg] https://apt.fury.io/wez/ stable main" | sudo tee /etc/apt/sources.list.d/wezterm.list
                # Update and install WezTerm
                sudo apt-get update
                sudo apt-get install -y wezterm
                ;;
            fedora)
                sudo dnf install -y dnf-plugins-core
                sudo dnf copr enable atim/wezterm -y
                sudo dnf install -y wezterm
                ;;
        esac
    else
        echo "WezTerm is already installed."
    fi
}

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

# Main script execution
detect_os
install_package "stow"   # Ensures GNU Stow is installed
install_lazygit
install_neovim
install_helix
install_wezterm
remove_existing_dirs
stow_dotfiles

echo "Setup completed successfully."

