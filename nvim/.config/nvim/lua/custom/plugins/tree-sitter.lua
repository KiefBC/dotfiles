return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local configs = require 'nvim-treesitter.configs'
    configs.setup {
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    }

    vim.cmd [[
  autocmd BufRead,BufNewFile *.html set filetype=javascript.jsx
]]
  end,
}
