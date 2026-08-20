return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    main = 'nvim-treesitter',
    config = function()
      local wanted = {
        'bash', 'c', 'cpp', 'css', 'go', 'gomod', 'gosum',
        'html', 'javascript', 'json', 'lua', 'luadoc',
        'markdown', 'markdown_inline', 'python', 'query',
        'rust', 'svelte', 'swift', 'toml', 'tsx',
        'typescript', 'vim', 'vimdoc', 'yaml',
      }
      local installed = require('nvim-treesitter').get_installed()
      local to_install = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, wanted)
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },
}
