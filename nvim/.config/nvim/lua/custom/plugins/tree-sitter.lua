return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    local configs = require 'nvim-treesitter.configs'
    configs.setup {
      auto_install = true,
      -- ensure_installed = { "lua", "cpp", "rust", "javascript", "typescript", "svelte", "python", "html", "css", "tsx" },
      highlight = { enable = true },
      indent = { enable = true },
    }

    vim.cmd [[
  autocmd BufRead,BufNewFile *.html set filetype=javascript.jsx
]]
  end,
}
