-- For `plugins/markview.lua` users.
return {
  'OXY2DEV/markview.nvim',
  lazy = false,

  -- For blink.cmp's completion
  -- source
  dependencies = {
    'saghen/blink.cmp',
  },
  config = function()
    local presets = require('markview.presets').headings

    require('markview').setup {
      markdown = {
        headings = presets.glow_center,
        horizontal_rules = presets.arrowed,
        tables = presets.single,
      },
    }
  end,
}
