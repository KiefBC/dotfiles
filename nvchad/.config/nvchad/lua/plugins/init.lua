return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
  			"vim", "lua", "vimdoc",
       "html", "css", "rust", "svelte", "cpp", "swift"
  		},
  	},
  },
  {
    -- INFO: Do not add this to MAson or LSP Config
    -- Rustacean does all of this for us.
    -- https://github.com/mrcjkb/rustaceanvim
    "mrcjkb/rustaceanvim",
    depdencies = {
      "adaszko/tree_climber_rust.nvim",
    },
    version = "^5",
    lazy = false,
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
    },
  },
  {
    -- INFO: This addeds better highlighting for Rust
    -- https://github.com/adaszko/tree_climber_rust.nvim
    "adaszko/tree_climber_rust.nvim",
    -- config = function()
    --   require('tree_climber_rust').setup()
    -- end,
  },
}
