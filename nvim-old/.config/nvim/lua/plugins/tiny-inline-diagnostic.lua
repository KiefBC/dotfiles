return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy', -- Or `LspAttach`
  priority = 1005, -- needs to be loaded in first
  config = function()
    require('tiny-inline-diagnostic').setup {
      preset = 'ghost',
      options = {
        multilines = true,
      },
    }
  end,
}
