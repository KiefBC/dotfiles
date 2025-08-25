return {
  'shahshlok/vim-coach.nvim',
  dependencies = {
    'folke/snacks.nvim',
  },
  config = function()
    require('vim-coach').setup()
  end,
  -- Note: Keymaps moved to lua/core/keymaps.lua for centralization
}
