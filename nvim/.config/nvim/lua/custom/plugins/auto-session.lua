return {
  'rmagatti/auto-session',
  config = function()
    local auto_session = require 'auto-session'
    auto_session.setup {
      auto_restore_enabled = false,
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    }

    local keymaps = vim.keymap
    keymaps.set('n', '<leader>wr', '<cmd>SessionRestore<CR>', { desc = '[R]estore Session' })
    keymaps.set('n', '<leader>wt', '<cmd>SessionSave<CR>', { desc = '[S]ave Session' })
  end,
}
