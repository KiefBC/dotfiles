return {
  -- INFO: Do not add this to Mason or LSP Config
  -- Rustacean does all of this for us.
  -- https://github.com/mrcjkb/rustaceanvim
  'mrcjkb/rustaceanvim',
  version = '^9',
  lazy = false,
  ft = { 'rust' },
  config = function()
    vim.g.rustaceanvim = {
      server = {
        on_attach = function(client, bufnr)
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
}
