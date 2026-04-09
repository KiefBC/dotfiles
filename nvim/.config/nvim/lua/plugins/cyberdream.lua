return {
  'scottmckendry/cyberdream.nvim',
  lazy = true,
  config = function()
    require('cyberdream').setup {
      -- Use solid background
      transparent = false,

      -- Visual enhancements
      italic_comments = true,

      -- Terminal colors
      terminal_colors = true,
    }

    -- vim.cmd 'colorscheme cyberdream'
  end,
}
