return {
  {
    'Zeioth/compiler.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    dependencies = {
      'stevearc/overseer.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {},
    -- Note: Keymaps moved to lua/core/keymaps.lua for centralization
  },
  { -- TODO: Configure to work with DAP, until then, config will be commented out
    'stevearc/overseer.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
    -- config = function()
    --   require('overseer').setup {
    --     strategy = 'toggleterm',
    --   }
    -- end,
  },
}
