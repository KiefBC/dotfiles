return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    null_ls.setup {
      autostart = true,
      sources = {
        -- Lua
        null_ls.builtins.formatting.stylua,
        -- CPP
        null_ls.builtins.formatting.clang_format,
        -- Javascript
        null_ls.builtins.formatting.prettier,
        -- null_ls.builtins.diagnostics.eslint_d,
        require 'none-ls.diagnostics.eslint',
        -- Python
        null_ls.builtins.formatting.black,
        -- require 'none-ls.formatting.ruff',
        -- require 'none-ls.diagnostics.ruff',
        -- require 'none-ls.diagnostics.flake8',
        -- null_ls.builtins.formatting.isort,
        -- require 'none-ls.formatting.autopep8',
        -- Rust
        -- null_ls.builtins.formatting.rustfmt,
        -- Shell/Bash
        null_ls.builtins.formatting.shfmt, -- Formatter
        null_ls.builtins.diagnostics.shellcheck, -- Linter
        null_ls.builtins.code_actions.shellcheck, -- Code actions
      },
    }
  end,
}
