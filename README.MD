# Dotfiles

Personal development environment configurations managed with GNU Stow.

## Tools

- **[Neovim](nvim/)** - Kickstart-based setup with LSP, Telescope, Copilot
- **[Helix](helix/)** - Modern modal editor
- **[WezTerm](wezterm/)** - GPU-accelerated terminal
- **[LazyGit](lazygit/)** - Git TUI

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install tools (macOS)
brew install stow neovim helix wezterm lazygit

# Deploy configurations
stow nvim helix wezterm lazygit

# Deploy individual configs
stow nvim

# Remove config
stow -D nvim
```

## Structure

Organized using GNU Stow convention:
```
tool-name/.config/tool-name/
```

Stow creates symlinks from `~/.config/tool-name` to this repository.

## License

MIT
