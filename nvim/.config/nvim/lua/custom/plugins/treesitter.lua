return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'windwp/nvim-ts-autotag',
    'ChimeHQ/Neon',
    -- 'ChimeHQ/SwiftTreeSitter',
  },
  config = function()
    local configs = require 'nvim-treesitter.configs'

    configs.setup {
      diagnostics = {
        disable = { 'missing-fields' },
      },
      ensure_installed = { 'rust', 'svelte', 'javascript', 'html', 'css', 'bash', 'lua', 'tsx', 'typescript', 'json', 'tsx', 'cpp', 'swift' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
        disable = { 'python', 'cpp', 'swift' }, -- INFO: Let my LSP's handle it.
      },
      autotag = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          scope_incremental = false,
          node_decremental = '<bs>',
        },
      },
    }

    -- This will highlight inline JSX on HTML files
    vim.api.nvim_command [[
      autocmd FileType html setlocal filetype=html.jsx
    ]]
  end,
}
