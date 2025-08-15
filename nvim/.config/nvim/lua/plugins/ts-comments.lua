return {
  'folke/ts-comments.nvim',
  dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
  opts = {},
  event = 'VeryLazy',
  enabled = vim.fn.has 'nvim-0.10.0' == 1,
}
