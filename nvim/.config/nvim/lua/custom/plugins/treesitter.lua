return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    local configs = require 'nvim-treesitter.configs'
    configs.setup {
      ensure_installed = { 'rust', 'svelte', 'javascript', 'html', 'css', 'bash', 'lua', 'tsx', 'typescript', 'json', 'tsx' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = { enable = true, disable = { 'python' } },
    }

    -- This will highlight inline JSX on HTML files
    vim.api.nvim_command [[
      autocmd FileType html setlocal filetype=html.jsx
    ]]
  end,
}
