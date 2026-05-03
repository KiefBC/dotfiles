return {
  'eldritch-theme/eldritch.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('eldritch').setup {}
    vim.cmd 'colorscheme eldritch-dark'
  end,
}
