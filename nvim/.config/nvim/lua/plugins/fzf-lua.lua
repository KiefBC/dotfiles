-- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#buffers-and-files

return {
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- calling `setup` is optional for customization
      require('fzf-lua').setup {
        winopts = {
          border = 'thicc',
          treesitter = true,
          -- INFO: Use these to move the fzf window around
          -- row = 3,
          -- col = 3,
          preview = {
            default = 'bat',
          },
        },
        -- For searching files in our CWD
        vim.keymap.set('n', '<leader>sf', function()
          require('fzf-lua').files { cwd = vim.uv.cwd() }
        end, { desc = 'Search [F]iles' }),

        -- Searching our buffers
        vim.keymap.set('n', '<leader>sb', function()
          require('fzf-lua').buffers {}
        end, { desc = 'Search [B]uffers' }),

        -- Grep for text
        vim.keymap.set('n', '<leader>sg', function()
          require('fzf-lua').live_grep {}
        end, { desc = 'Search [G]rep' }),
      }
    end,
  },
}
