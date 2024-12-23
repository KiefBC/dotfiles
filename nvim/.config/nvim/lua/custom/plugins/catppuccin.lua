return {
  'catppuccin/nvim',
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha', -- choose your Catppuccin flavor: latte, frappe, macchiato, mocha
      transparent_background = true,
      integrations = {
        blink_cmp = true,
        dashboard = true,
        fzf = true,
        mason = true,
        noice = true,
        notifier = true,
      },
    }
    vim.cmd 'colorscheme catppuccin'
  end,
}
