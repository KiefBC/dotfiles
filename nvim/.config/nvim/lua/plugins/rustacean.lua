return {
  {
    -- INFO: Do not add this to Mason or LSP Config
    -- Rustacean does all of this for us.
    -- https://github.com/mrcjkb/rustaceanvim
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    ft = { 'rust' },
    dependencies = {
      'adaszko/tree_climber_rust.nvim',
    },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            -- Tree climber keybindings for Rust
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set('n', 's', '<cmd>lua require("tree_climber_rust").init_selection()<CR>', opts)
            vim.keymap.set('x', 's', '<cmd>lua require("tree_climber_rust").select_incremental()<CR>', opts)
            vim.keymap.set('x', 'S', '<cmd>lua require("tree_climber_rust").select_previous()<CR>', opts)

            -- Use standard LSP code action with Telescope picker (same as other languages)
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { silent = true, buffer = bufnr, desc = '[C]ode [A]ction' })
            vim.keymap.set('x', '<leader>ca', vim.lsp.buf.code_action, { silent = true, buffer = bufnr, desc = '[C]ode [A]ction' })

            -- Additional Rust-specific actions
            vim.keymap.set('n', '<leader>cr', function()
              vim.cmd.RustLsp 'runnables'
            end, { silent = true, buffer = bufnr, desc = '[C]ode [R]unnables' })

            vim.keymap.set('n', '<leader>ce', function()
              vim.cmd.RustLsp 'explainError'
            end, { silent = true, buffer = bufnr, desc = '[C]ode [E]xplain Error' })

            vim.keymap.set('n', '<leader>cm', function()
              vim.cmd.RustLsp 'expandMacro'
            end, { silent = true, buffer = bufnr, desc = '[C]ode Expand [M]acro' })
          end,
          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
            },
          },
        },
      }
    end,
  },
  {
    -- INFO: This is for managing our Rust crates
    -- https://github.com/Saecki/crates.nvim
    {
      'saecki/crates.nvim',
      event = { 'BufRead Cargo.toml' },
      config = function()
        require('crates').setup()
      end,
    },
  },
  {
    -- INFO: This addeds better highlighting for Rust
    -- https://github.com/adaszko/tree_climber_rust.nvim
    'adaszko/tree_climber_rust.nvim',
    -- config = function()
    --   require('tree_climber_rust').setup()
    -- end,
  },
}
