return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = {
    {
      'nvim-lua/plenary.nvim',
    },
  },
  config = function()
    require('todo-comments').setup {
      signs = true, -- show icons in the signs column
      keywords = {
        FIX = {
          icon = ' ', -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'ERROR' }, -- a set of other keywords that all map to this FIX
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
      },
      highlight = {
        before = '', -- "fg" or "bg" or empty
        keyword = 'wide', -- "wide" or "block" or "wide block"
        after = 'fg', -- "fg" or "bg" or empty
      },
      search = {
        command = 'rg',
        args = {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]],
      },
    }
  end,
}
