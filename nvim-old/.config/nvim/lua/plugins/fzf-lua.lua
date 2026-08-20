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
      }
    end,
  },
}
