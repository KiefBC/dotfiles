#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS. Please use the manual installation instructions for other platforms."
    exit 1
fi

# Check if script is run as root
if [ "$(id -u)" -eq 0 ]; then
    print_error "Please don't run this script as root/sudo"
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install Homebrew if not installed
install_homebrew() {
    if ! command_exists brew; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        print_status "Homebrew is already installed"
    fi
}

# Function to install a package via Homebrew
install_with_brew() {
    local package=$1
    local cask=${2:-false}
    
    if [ "$cask" = true ]; then
        if brew list --cask "$package" &> /dev/null; then
            print_status "$package is already installed"
        else
            print_status "Installing $package..."
            brew install --cask "$package"
        fi
    else
        if brew list "$package" &> /dev/null; then
            print_status "$package is already installed"
        else
            print_status "Installing $package..."
            brew install "$package"
        fi
    fi
}

# Function to install Node.js and npm
install_node() {
    if ! command_exists node || ! command_exists npm; then
        print_status "Installing Node.js and npm..."
        install_with_brew node
    else
        print_status "Node.js and npm are already installed"
        print_status "Node version: $(node --version)"
        print_status "npm version: $(npm --version)"
    fi
}

# Function to backup existing configurations
backup_configs() {
    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    local made_backup=false
    
    for dir in nvim helix wezterm lazygit; do
        if [ -d "$HOME/.config/$dir" ]; then
            if [ "$made_backup" = false ]; then
                print_status "Creating backup of existing configurations at $backup_dir"
                mkdir -p "$backup_dir"
                made_backup=true
            fi
            cp -r "$HOME/.config/$dir" "$backup_dir/"
            print_status "Backed up $dir configuration"
        fi
    done
}

# Function to deploy dotfiles with stow
deploy_dotfiles() {
    print_status "Deploying dotfiles with GNU Stow..."
    
    # Get the directory where the script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd "$SCRIPT_DIR"
    
    # Deploy each configuration
    for dir in nvim helix wezterm lazygit; do
        if [ -d "$dir" ]; then
            print_status "Deploying $dir configuration..."
            stow -v "$dir"
        else
            print_warning "Directory $dir not found, skipping..."
        fi
    done
}

# Function to install additional requirements
install_additional_requirements() {
    print_status "Checking for additional requirements..."
    
    # Install ripgrep for better search in Neovim
    install_with_brew ripgrep
    
    # Install fd for better file finding
    install_with_brew fd
    
    # Install fzf for fuzzy finding
    install_with_brew fzf
    
    # Install tree-sitter CLI for Neovim
    install_with_brew tree-sitter
    
    # Install language servers and tools
    print_status "Installing language servers and development tools..."
    
    # Rust toolchain
    if ! command_exists rustc; then
        print_status "Installing Rust toolchain..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Python tools
    install_with_brew python3
    
    # Install Nerd Font
    print_status "Installing JetBrainsMono Nerd Font..."
    brew tap homebrew/cask-fonts
    install_with_brew font-jetbrains-mono-nerd-font true
}

# Main installation flow
main() {
    print_status "Starting dotfiles setup for macOS..."
    
    # Install Homebrew
    install_homebrew
    
    # Update Homebrew
    print_status "Updating Homebrew..."
    brew update
    
    # Install core tools
    print_status "Installing core tools..."
    install_with_brew stow
    install_with_brew neovim
    install_with_brew helix
    install_with_brew wezterm true  # WezTerm is a cask
    install_with_brew lazygit
    
    # Install Node.js and npm
    install_node
    
    # Install additional requirements
    install_additional_requirements
    
    # Ask user if they want to backup existing configs
    read -p "Do you want to backup existing configurations? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        backup_configs
    fi
    
    # Deploy dotfiles
    deploy_dotfiles
    
    print_status "Setup completed successfully!"
    print_status "Please restart your terminal or source your shell configuration"
    
    # Post-installation notes
    echo
    print_status "Post-installation notes:"
    echo "  - Neovim will install plugins on first launch"
    echo "  - You may need to run :checkhealth in Neovim to verify everything is working"
    echo "  - WezTerm configuration is ready to use"
    echo "  - LazyGit is configured to use Neovim as the default editor"
}

# Run main function
main