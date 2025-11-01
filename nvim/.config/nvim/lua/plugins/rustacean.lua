return {
  {
    -- INFO: Do not add this to MAson or LSP Config
    -- Rustacean does all of this for us.
    -- https://github.com/mrcjkb/rustaceanvim
    'mrcjkb/rustaceanvim',
    depdencies = {
      'adaszko/tree_climber_rust.nvim',
    },
    version = '^5',
    lazy = false,
    ['rust-analyzer'] = {
      cargo = {
        allFeatures = true,
      },
    },
    server = {
      on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(bufnr, 'n', 's', '<cmd>lua require("tree_climber_rust").init_selection()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'x', 's', '<cmd>lua require("tree_climber_rust").select_incremental()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, 'x', 'S', '<cmd>lua require("tree_climber_rust").select_previous()<CR>', opts)
      end,
    },
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
