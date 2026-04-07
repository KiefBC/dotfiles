return {
  -- INFO: Copilot for nvim
  -- https://github.com/zbirenbaum/copilot.lua
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false, -- handled in blink keymap
          next = '<C-n>',
          prev = '<C-p>',
          dismiss = '<C-]>',
        },
      },
      panel = { enabled = false },
    }
  end,
}
