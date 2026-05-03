return {
  -- INFO: My favorite theme
  -- https://github.com/catppuccin/nvim
  'catppuccin/nvim',
  name = 'catppuccin',
  lazy = false,
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'macchiato',
      integrations = {
        blink_cmp = true,
        dashboard = true,
        fzf = true,
        mason = true,
        noice = true,
        notifier = true,
        snacks = { enabled = true },
      },
    }
    -- vim.cmd 'colorscheme catppuccin'
  end,
}
