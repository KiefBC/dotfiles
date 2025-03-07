return {
  -- INFO: Adds easy commenting
  -- https://github.com/numToStr/Comment.nvim
  'numToStr/Comment.nvim',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = { 'joosepalviste/nvim-ts-context-commentstring' },
  keys = {
    -- TODO: Look into custom mapping, :h Comment
    -- INFO: After <leader>V, press . to continue commenting
    { '<Leader>V', '<Plug>(comment_toggle_blockwise_current)', mode = 'n', desc = 'Comment' },
    { '<Leader>V', '<Plug>(comment_toggle_blockwise_visual)', mode = 'x', desc = 'Comment' },
  },

  opts = function(_, opts)
    local ok, tcc = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
    if ok then
      opts.pre_hook = tcc.create_pre_hook()
    end
  end,
}
