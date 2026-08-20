return {
  -- INFO: This is for nvim-cmp compatibility with blink.cmp
  -- https://github.com/Saghen/blink.compat
  'saghen/blink.compat',
  version = '*',
  lazy = true,
  opts = {
    keymap = {
      ['<Tab>'] = {
        'snippet_forward',
        function() -- sidekick next edit suggestion
          return require('sidekick').nes_jump_or_apply()
        end,
        function() -- if you are using Neovim's native inline completions
          return vim.lsp.inline_completion.get()
        end,
        'fallback',
      },
    },
  },
}
