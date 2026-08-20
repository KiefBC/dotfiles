return {
  -- INFO: This is for managing our Rust crates
  -- https://github.com/Saecki/crates.nvim
  'saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  config = function()
    require('crates').setup {
      lsp = {
        enabled = true,
        on_attach = function(client, bufnr) end,
        actions = true,
        completion = true,
        hover = true,
      },
    }
  end,
}
