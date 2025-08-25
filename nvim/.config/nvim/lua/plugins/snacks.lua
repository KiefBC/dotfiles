return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    notifier = {
      enabled = true,
      style = 'fancy',
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    input = {},
    term = { enabled = true },
    scratch = { enabled = true },
    dashboard = { enabled = true },
    lazygit = { enabled = true },
    debug = { enabled = true },
    win = { enabled = true },
  },
}
