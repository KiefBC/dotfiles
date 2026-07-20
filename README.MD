# Dotfiles

Personal development environment configurations managed with GNU Stow.

## Tools

- **[Neovim](nvim/)** - Kickstart-based setup with LSP, Telescope, Copilot
- **[Helix](helix/)** - Modern modal editor
- **[WezTerm](wezterm/)** - GPU-accelerated terminal
- **[Ghostty](ghostty/)** - Fast, native terminal
- **[Zed](zed/)** - High-performance editor
- **[LazyGit](lazygit/)** - Git TUI
- **[Claude Code](claude/)** - AI coding agent config (settings, hooks, skills)

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install tools (macOS)
brew install stow neovim helix lazygit
brew install --cask wezterm ghostty zed claude-code

# Deploy configurations
stow nvim helix wezterm lazygit ghostty zed claude

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

Stow creates symlinks from `~/.config/tool-name` to this repository. The `claude` package is the exception: it symlinks into `~/.claude`.

## License

MIT
