return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Define the timerly status function
    local function get_timerly_status()
      local ok, state = pcall(require, 'timerly.state')
      if not ok then
        return ''
      end

      if state.progress == 0 then
        return ''
      end

      local total = math.max(0, state.total_secs + 1)
      local mins = math.floor(total / 60)
      local secs = total % 60

      return string.format('%s %02d:%02d', state.mode:gsub('^%l', string.upper), mins, secs)
    end

    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == '' then
        return ''
      end
      return 'recording @' .. reg
    end

    require('lualine').setup {
      options = {
        theme = 'eldritch', -- auto before
      },
      sections = {
        lualine_x = {
          { macro_recording, color = { fg = '#ff5555', gui = 'bold' } },
          get_timerly_status,
        },
      },
    }

    vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
      callback = function()
        require('lualine').refresh()
      end,
    })
  end,
}
