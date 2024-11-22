return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Define the timerly status function
    local function get_timerly_status()
      local ok, state = pcall(require, "timerly.state")
      if not ok then return "" end
      
      if state.progress == 0 then
        return ""
      end

      local total = math.max(0, state.total_secs + 1)
      local mins = math.floor(total / 60)
      local secs = total % 60

      return string.format("%s %02d:%02d", state.mode:gsub("^%l", string.upper), mins, secs)
    end

    require('lualine').setup {
      options = {
        theme = 'dracula',
      },
      sections = {
        lualine_x = {
          get_timerly_status,
        },
      },
    }
  end,
}
