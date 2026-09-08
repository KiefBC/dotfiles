# Neovim (NixOS)

The `nvim` config with Mason removed, for machines where NixOS provides the
toolchain. Everything else — keymaps, options, plugins, theme — is unchanged,
so fixes to `nvim` should generally be ported across.

## What differs from `nvim`

| | `nvim` | `nvim-nixos` |
|---|---|---|
| Servers, formatters, adapters | `mason.nvim` downloads them into `~/.local/share/nvim/mason` | declared in `/etc/nixos/configuration.nix`, found on `PATH` |
| Server startup | `mason-lspconfig`'s `automatic_enable` | `vim.lsp.enable()` over an explicit list |
| Tool installation | `mason-tool-installer` `ensure_installed` | nothing at runtime |
| `codelldb` / `debugpy` | Mason store paths | `vim.fn.exepath()` |

`nvim-lspconfig` is still used — it supplies the server definitions that
`vim.lsp.enable()` reads. `rust_analyzer` is not in the enable list because
rustaceanvim starts it.

If a server binary is missing, startup prints one warning naming it rather than
erroring on every matching buffer.

## Requires

Neovim 0.12+ (`vim.pack`), plus the packages listed under the "Neovim
toolchain" comment in `/etc/nixos/configuration.nix`:

- **Servers** — `rust-analyzer`, `lua-language-server`, `gopls`, `clang-tools`,
  `ruff`, `ty`, `tailwindcss-language-server`
- **Formatters** — `stylua`, `gotools`, `sqruff`, `prettierd`, `prettier`,
  `shfmt`, `taplo`
- **Debug adapters** — `vscode-extensions.vadimcn.vscode-lldb.adapter`,
  `delve`, and a `python3.withPackages` carrying `debugpy`
- **Treesitter** — `tree-sitter` and `gcc`; nvim-treesitter compiles its own
  parsers into `~/.local/share/nvim/site/parser`, and shells out to both

No `nvim-pack-lock.json` is committed. This package shares a plugin directory
with `nvim`, so a lock written here picks up that config's mason plugins;
`vim.pack` regenerates it on first launch.

`programs.neovim.configure` must stay empty there: a Nix-managed
`nvim-treesitter` collides with the one `vim.pack` installs.

## Install

Both neovim packages stow to `~/.config/nvim`, so only one can be active:

```bash
cd ~/dotfiles
stow -D nvim
stow nvim-nixos
```

Adding a server means editing two files: the `servers`/`server_cmd` tables in
`init.lua`, and `environment.systemPackages` in `configuration.nix`.
