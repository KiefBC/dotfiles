return {
  'catppuccin/nvim',
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha', -- choose your Catppuccin flavor: latte, frappe, macchiato, mocha
    }
    vim.cmd 'colorscheme catppuccin'
  end,
}
