return {
  'scottmckendry/cyberdream.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('cyberdream').setup {
      -- Use solid background
      transparent = false,

      -- Visual enhancements
      italic_comments = true,

      -- Terminal colors
      terminal_colors = true,
    }

    -- Set as active colorscheme
    vim.cmd 'colorscheme cyberdream'
  end,
}
