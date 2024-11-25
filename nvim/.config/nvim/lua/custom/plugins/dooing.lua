return {
  'atiladefreitas/dooing',
  config = function()
    require('dooing').setup {
      -- your custom config here (optional)
    }
  end,
  keys = {
    {
      '<leader>zt',
      function()
        require('dooing.ui').toggle_todo_window()
      end,
      desc = '[T]oggle Todo List',
      remap = true,
    },
  },
}
