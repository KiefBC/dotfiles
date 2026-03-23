return {
  -- INFO: Copilot for nvim
  -- https://github.com/zbirenbaum/copilot.lua
  'zbirenbaum/copilot.lua',
  dependencies = {
    -- INFO: Adds copilot suggestions to blink.cmp
    -- https://github.com/giuxtaposition/blink-cmp-copilot
    'giuxtaposition/blink-cmp-copilot',
  },
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
    }
  end,
}
