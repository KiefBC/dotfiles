return {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    local config = require 'mason'
    local mason_lspconfig = require 'mason-lspconfig'
    local mason_tool_installer = require 'mason-tool-installer'
    config.setup {}
    mason_lspconfig.setup {
      ensure_installed = {
        'lua_ls',
        'bashls',
        'ts_ls',
        'svelte',
        'tailwindcss',
        'html',
        'cssls',
        'emmet_ls',
      },
    }
    mason_tool_installer.setup {
      ensure_installed = {
        'stylua',
        'ruff',
        'prettierd',
        'shfmt',
        'pylint',
        'eslint_d',
      },
    }
  end,
}
