# Dotfiles

Personal development environment configurations for Neovim, Helix, WezTerm, and LazyGit.

## Overview

This repository contains my personal dotfiles organized with GNU Stow for easy deployment and management. It includes configurations for multiple text editors, a modern terminal emulator, and development tools with a focus on consistency and productivity.

## Tools Configured

- **[Neovim](nvim/)** - Primary editor with extensive plugin ecosystem (Kickstart-based)
- **[Helix](helix/)** - Modern modal editor with built-in features
- **[WezTerm](wezterm/)** - GPU-accelerated terminal emulator
- **[LazyGit](lazygit/)** - Terminal UI for Git

## Quick Start

### Prerequisites

- Git
- [GNU Stow](https://www.gnu.org/software/stow/)
- The tools you want to configure (Neovim, Helix, WezTerm, LazyGit)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Deploy all configurations:
```bash
stow nvim helix wezterm lazygit
```

Or deploy specific configurations:
```bash
stow nvim  # Just Neovim
stow wezterm  # Just WezTerm
```

3. Remove a configuration:
```bash
stow -D nvim
```

### Manual Installation

The `setup.sh` script is currently out of date. For now, manually install the required tools:

- **macOS**: Use [Homebrew](https://brew.sh/)
  ```bash
  brew install stow neovim helix wezterm lazygit
  ```

- **Ubuntu/Debian**:
  ```bash
  sudo apt install stow
  # Follow tool-specific installation instructions
  ```

- **Fedora**:
  ```bash
  sudo dnf install stow
  # Follow tool-specific installation instructions
  ```

## Configuration Details

### Neovim

My primary Neovim setup is based on Kickstart.nvim with extensive customizations:

- **Plugin Manager**: Lazy.nvim
- **Key Features**:
  - Telescope fuzzy finder with FZF
  - Full LSP support for multiple languages
  - Treesitter for syntax highlighting
  - GitHub Copilot integration
  - Rustacean for enhanced Rust development
  - Catppuccin color scheme
- **Leader Key**: Space

### WezTerm

Cross-platform terminal configuration with:
- **Theme**: Custom Cyberdream implementation
- **Font**: JetBrainsMono Nerd Font (size 14)
- **Features**: Semi-transparent background, macOS blur, custom keybindings

### Helix

Alternative modal editor with:
- **Theme**: kanabox_default
- **Languages**: 100+ language support with custom themes

### LazyGit

Git TUI with:
- **Integration**: Neovim as default editor
- **Features**: Nerd Fonts v3, branch-specific colors

## Structure

Each tool follows the GNU Stow convention:
```
tool-name/
  .config/
    tool-name/
      [configuration files]
```

This structure allows Stow to create symlinks from `~/.config/tool-name` to the repository.

## Contributing

These are personal configurations, but feel free to fork and adapt them for your own use.

## License

MIT
