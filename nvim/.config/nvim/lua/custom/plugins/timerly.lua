return {
  'nvzone/timerly',
  dependencies = {
    'nvzone/volt',
  },
  config = function()
    require('timerly').setup {
      default_timer = 'volt',
      presets = {
        pomodoro = {
          work = 25 * 60,    -- 25 minutes
          short_break = 5 * 60,  -- 5 minutes
          long_break = 15 * 60,  -- 15 minutes
        },
      },
      notify = {
        enabled = true,
        timeout = 5000,      -- 5 seconds
        sound = true,        -- Enable sound notifications
      },
      keymaps = {
        toggle = '<leader>tt',  -- Toggle timer
        reset = '<leader>tr',   -- Reset timer
        next = '<leader>tn',    -- Next timer
      },
      ui = {
        show_seconds = true,
        show_mode = true,
        position = 'top',    -- or 'bottom'
      },
      volt = {
        enabled = true,
        auto_start = true,
      },
    }

    vim.api.nvim_create_user_command('Pomodoro', function()
      require('timerly').start('pomodoro.work')
    end, {})

    vim.api.nvim_create_user_command('Break', function()
      require('timerly').start('pomodoro.short_break')
    end, {})

    vim.api.nvim_create_user_command('LongBreak', function()
      require('timerly').start('pomodoro.long_break')
    end, {})
  end,
  keys = {
    { '<leader>tt', '<cmd>TimerlyToggle<cr>', desc = 'Toggle Timer' },
    { '<leader>tr', '<cmd>TimerlyReset<cr>', desc = 'Reset Timer' },
    { '<leader>tn', '<cmd>TimerlyNext<cr>', desc = 'Next Timer' },
  },
}
