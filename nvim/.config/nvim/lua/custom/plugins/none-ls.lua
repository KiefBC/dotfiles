return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'gbprod/none-ls-shellcheck.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local shellcheck = require 'none-ls-shellcheck'

    null_ls.setup {
      autostart = true,
      sources = {
        -- Lua
        null_ls.builtins.formatting.stylua,
        -- CPP
        -- null_ls.builtins.formatting.clang_format,
        -- Javascript / HTML / CSS
        -- null_ls.builtins.formatting.prettierd,
        -- null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.rustywind,
        require 'none-ls.diagnostics.eslint',
        -- Python
        -- null_ls.builtins.formatting.black,
        -- require 'none-ls.formatting.ruff',
        -- require 'none-ls.diagnostics.ruff',
        -- require 'none-ls.diagnostics.flake8',
        -- null_ls.builtins.formatting.isort,
        -- require 'none-ls.formatting.autopep8',
        -- Rust
        -- null_ls.builtins.formatting.rustfmt,
        -- Shell/Bash
        null_ls.builtins.formatting.shfmt, -- Formatter
        shellcheck.diagnostics, -- Linter
        shellcheck.code_actions, -- Code actions
      },
    }
  end,
}
