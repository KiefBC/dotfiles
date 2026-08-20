return {
  -- INFO: It does what it says...
  -- https://github.com/windwp/nvim-autopairs
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true, -- enable treesitter
      ts_config = {
        lua = { 'string' }, -- it will not add a pair on that treesitter node
        javascript = { 'template_string' },
        java = false, -- don't check treesitter on java
      },
    }
  end,
}
