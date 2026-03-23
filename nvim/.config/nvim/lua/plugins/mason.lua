return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup {}
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup {
        ensure_installed = {
          -- LSP servers
          'lua-language-server',
          'bash-language-server',
          'typescript-language-server',
          'svelte-language-server',
          'tailwindcss-language-server',
          'html-lsp',
          'css-lsp',
          'emmet-ls',
          'json-lsp',
          'gopls',
          'ty',
          -- Formatters
          'stylua',
          'prettierd',
          'prettier',
          'shfmt',
          'sqls',
          'goimports',
          'sql-formatter',
          -- Linters
          'ruff',
          'pylint',
          'eslint_d',
          'markdownlint',
          -- DAP
          'codelldb',
        },
      }
    end,
  },
}
