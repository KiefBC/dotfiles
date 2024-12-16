return {
  -- Load mason.nvim first
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup {}
    end,
  },
  -- Then load mason-lspconfig.nvim after mason.nvim
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup {
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
    end,
  },
  -- Finally, load mason-tool-installer.nvim after mason.nvim
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',
          'ruff',
          'prettierd',
          'shfmt',
          'pylint',
          'eslint_d',
          'codelldb',
        },
      }
    end,
  },
}
