# Dotfiles

Personal development environment configurations managed with GNU Stow.

## Tools

- **[Neovim](nvim/)** - `vim.pack` setup with LSP, DAP, Mason-managed tooling
- **[Neovim (NixOS)](nvim-nixos/)** - the same config with Mason removed; the toolchain comes from `configuration.nix`
- **[Helix](helix/)** - Modern modal editor
- **[Ghostty](ghostty/)** - Fast, native terminal
- **[Zed](zed/)** - High-performance editor
- **[LazyGit](lazygit/)** - Git TUI
- **[Claude Code](claude/)** - AI coding agent config (settings, hooks, skills)

## Installation

```bash
# Clone repository
git clone git@github.com:KiefBC/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install tools (macOS)
brew install stow neovim helix lazygit
brew install --cask ghostty zed claude-code

# Deploy configurations
stow nvim helix lazygit ghostty zed claude codex

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

Stow creates symlinks from `~/.config/tool-name` to this repository. `claude` and `codex` are the exceptions: they symlink into `~/.claude` and `~/.codex`.

`nvim` and `nvim-nixos` both target `~/.config/nvim`, so only one can be stowed at a time. Only `nvim` is in `setup.sh`'s package list; swap by hand:

```bash
stow -D nvim && stow nvim-nixos
```

## License

MIT
