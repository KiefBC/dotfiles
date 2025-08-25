return {
  -- INFO: Adds easy commenting
  -- https://github.com/numToStr/Comment.nvim
  'numToStr/Comment.nvim',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = { 'joosepalviste/nvim-ts-context-commentstring' },
  -- Note: Keymaps moved to lua/core/keymaps.lua for centralization

  opts = function(_, opts)
    local ok, tcc = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
    if ok then
      opts.pre_hook = tcc.create_pre_hook()
    end
  end,
}
