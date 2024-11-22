-- lua/plugins/compiler.lua
return {
  {
    'Zeioth/compiler.nvim',
    dependencies = {
      'stevearc/overseer.nvim',
      'nvim-telescope/telescope.nvim',
    },
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    opts = {},
    -- Optional: Add key mappings for compiler.nvim
    keys = {
      {
        '<leader>tc',
        '<cmd>CompilerOpen<cr>',
        desc = 'Open Compiler',
      },
      {
        '<leader>tr',
        '<cmd>CompilerToggleResults<cr>',
        desc = 'Toggle Compiler Results',
      },
      {
        '<leader>td',
        '<cmd>CompilerRedo<cr>',
        desc = 'Redo Last Compiler Action',
      },
    },
  },
  {
    'stevearc/overseer.nvim',
    commit = '6271cab7ccc4ca840faa93f54440ffae3a3918bd',
    cmd = { 'CompilerOpen', 'CompilerToggleResults', 'CompilerRedo' },
    opts = {
      task_list = {
        direction = 'bottom',
        min_height = 25,
        max_height = 25,
        default_detail = 1,
        bindings = {
          ['?'] = 'ShowHelp',
          ['<CR>'] = 'RunAction',
          ['<C-e>'] = 'Edit',
          ['o'] = 'Open',
          ['<C-v>'] = 'OpenVsplit',
          ['<C-s>'] = 'OpenSplit',
          ['<C-f>'] = 'OpenFloat',
          ['<C-q>'] = 'OpenQuickFix',
          ['p'] = 'TogglePreview',
          ['<C-l>'] = 'IncreaseDetail',
          ['<C-h>'] = 'DecreaseDetail',
          ['L'] = 'IncreaseAllDetail',
          ['H'] = 'DecreaseAllDetail',
          ['['] = 'DecreaseWidth',
          [']'] = 'IncreaseWidth',
          ['{'] = 'PrevTask',
          ['}'] = 'NextTask',
        },
      },
    },
    -- Optional: Add additional overseer configuration
    config = function(_, opts)
      require('overseer').setup(opts)

      -- You can add templates for your common build tasks here
      require('overseer').register_template {
        name = 'Build Project',
        builder = function()
          return {
            cmd = { 'make' }, -- Replace with your build command
            components = { 'default' },
          }
        end,
        condition = {
          filetype = { 'cpp', 'c', 'rust' }, -- Add your project filetypes
        },
      }
    end,
  },
}
