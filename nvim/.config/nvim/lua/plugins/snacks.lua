return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    notifier = {
      enabled = true,
      style = 'fancy',
    },
    explorer = {
      enabled = true,
      git_status = true,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    input = {},
    term = { enabled = true },
    scratch = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = '██╗  ██╗██╗███████╗███████╗██╗  ██╗\n██║ ██╔╝██║██╔════╝██╔════╝╚██╗██╔╝\n█████╔╝ ██║█████╗  █████╗   ╚███╔╝ \n██╔═██╗ ██║██╔══╝  ██╔══╝   ██╔██╗ \n██║  ██╗██║███████╗██║     ██╔╝ ██╗\n╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝',
      },
    },
    lazygit = { enabled = true },
    debug = { enabled = true },
    win = { enabled = true },
    terminal = {
      win = {
        style = 'terminal', -- Use the default terminal window style
      },
    },
    picker = { enabled = true },
  },
  keys = {
    {
      '<leader>e',
      function()
        Snacks.explorer()
      end,
      desc = 'EXPLORE TEST',
    },
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Delete [B]uffer',
    },
    -- Toggle default terminal with Ctrl+/
    {
      '<c-/>',
      function()
        Snacks.terminal()
      end,
      desc = 'Toggle Terminal',
    },
    {
      '<c-_>', -- Some terminals send <c-_> instead of <c-/>
      function()
        Snacks.terminal()
      end,
      desc = 'which_key_ignore',
    },
    -- Leader-based terminal commands
    {
      '<leader>tt',
      function()
        Snacks.terminal()
      end,
      desc = '[T]erminal [T]oggle',
    },
    {
      '<leader>t+',
      function()
        Snacks.terminal.open()
      end,
      desc = '[T]erminal [N]ew',
    },
    {
      '<leader>tl',
      function()
        local terminals = Snacks.terminal.list()
        if #terminals == 0 then
          vim.notify('No active terminals', vim.log.levels.INFO)
          return
        end
        vim.ui.select(terminals, {
          prompt = 'Select terminal:',
          format_item = function(term)
            return string.format('Terminal %d: %s', term.id, term.cmd or 'shell')
          end,
        }, function(choice)
          if choice then
            choice:toggle()
          end
        end)
      end,
      desc = '[T]erminal [L]ist',
    },
  },
}
