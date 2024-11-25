return {
  {
    'Zeioth/compiler.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    dependencies = {
      'stevearc/overseer.nvim',
      'nvim-telescope/telescope.nvim',
    },
    opts = {},
    keys = {
      -- Code Compile Options
      { '<leader>cco', '<cmd>CompilerOpen<cr>', desc = 'Open [C]ompiler' },
      { '<leader>ccr', '<cmd>CompilerRedo<cr>', desc = 'Redo [C]ompiler' },
      { '<leader>ccs', '<cmd>CompilerToggleResults<cr>', desc = 'Toggle [C]ompiler [S]tate' },

      -- { '<leader>cco', '<cmd>CompilerOpen<cr>', desc = 'Open Compiler' },
      --  {
      --    '<S-F3>',
      --    function()
      --      vim.cmd 'CompilerStop'
      --      vim.cmd 'CompilerRedo'
      --    end,
      --    desc = 'Redo Compiler',
      --  },
      -- { '<F4>', '<cmd>CompilerToggleResults<cr>', desc = 'Toggle Compiler Results' },
    },
  },
  { -- TODO: Configure to work with DAP
    'stevearc/overseer.nvim',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
      },
    },
    config = function()
      require('overseer').setup {
        strategy = 'toggleterm',
      }
    end,
  },
}
