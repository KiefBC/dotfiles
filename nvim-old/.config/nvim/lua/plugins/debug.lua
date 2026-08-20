-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'codelldb', -- Rust debugger
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- Rust debugging configuration
    dap.configurations.rust = {
      {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
      {
        name = 'Debug Test',
        type = 'codelldb',
        request = 'launch',
        program = function()
          -- Build test binary and capture output
          vim.notify('Building tests...', vim.log.levels.INFO)
          local build_output = vim.fn.system 'cargo test --no-run --message-format=json 2>&1'

          -- Parse JSON output to find test executable
          local executables = {}
          for line in build_output:gmatch '[^\r\n]+' do
            local ok, json = pcall(vim.fn.json_decode, line)
            if ok and json and json.executable and json.profile and json.profile.test then
              table.insert(executables, json.executable)
            end
          end

          if #executables > 0 then
            -- Return the most recent test executable (usually the last one)
            return executables[#executables]
          end

          -- Fallback: try to find test executables in deps directory
          local deps_dir = vim.fn.getcwd() .. '/target/debug/deps/'
          local find_cmd = string.format("find '%s' -type f -perm +111 -newer '%s../build' 2>/dev/null | grep -v '\\.d$' | tail -1", deps_dir, deps_dir)
          local found_exec = vim.fn.system(find_cmd):gsub('%s+$', '')

          if found_exec ~= '' and vim.fn.filereadable(found_exec) == 1 then
            return found_exec
          end

          vim.notify('Could not find test executable. Please select manually.', vim.log.levels.WARN)
          return vim.fn.input('Path to test executable: ', deps_dir, 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
      },
      {
        name = 'Debug Current Test',
        type = 'codelldb',
        request = 'launch',
        program = function()
          -- Build test binary and capture output
          vim.notify('Building tests...', vim.log.levels.INFO)
          local build_output = vim.fn.system 'cargo test --no-run --message-format=json 2>&1'

          -- Parse JSON output to find test executable
          local executables = {}
          for line in build_output:gmatch '[^\r\n]+' do
            local ok, json = pcall(vim.fn.json_decode, line)
            if ok and json and json.executable and json.profile and json.profile.test then
              table.insert(executables, json.executable)
            end
          end

          if #executables > 0 then
            -- Return the most recent test executable (usually the last one)
            return executables[#executables]
          end

          -- Fallback: try to find test executables in deps directory
          local deps_dir = vim.fn.getcwd() .. '/target/debug/deps/'
          local find_cmd = string.format("find '%s' -type f -perm +111 -newer '%s../build' 2>/dev/null | grep -v '\\.d$' | tail -1", deps_dir, deps_dir)
          local found_exec = vim.fn.system(find_cmd):gsub('%s+$', '')

          if found_exec ~= '' and vim.fn.filereadable(found_exec) == 1 then
            return found_exec
          end

          vim.notify('Could not find test executable. Please select manually.', vim.log.levels.WARN)
          return vim.fn.input('Path to test executable: ', deps_dir, 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = function()
          -- Get test name under cursor
          local test_name = vim.fn.expand '<cword>'
          if test_name ~= '' then
            return { test_name, '--exact', '--nocapture' }
          end
          return { '--nocapture' }
        end,
      },
    }
  end,
}
