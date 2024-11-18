return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls' },
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'j-hui/fidget.nvim', {} },
      { 'hrsh7th/cmp-nvim-lsp' },
    },
    config = function()
      local lspconfig = require 'lspconfig'
      lspconfig.lua_ls.setup {}
      lspconfig.clangd.setup {
        cmd = { 'clangd' },
      }
      lspconfig.pyright.setup {}
    end,
  },
}
