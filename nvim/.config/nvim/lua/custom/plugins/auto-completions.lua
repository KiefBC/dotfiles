return {
  {
    -- INFO: Copilot for nvim
    -- https://github.com/zbirenbaum/copilot.lua
    -- TODO: Work on adding this to Blink CMP
    'zbirenbaum/copilot.lua',
    dependencies = {
      -- INFO: Adds copilot suggestions to blink.cmp
      -- https://github.com/giuxtaposition/blink-cmp-copilot
      'giuxtaposition/blink-cmp-copilot',
    },
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = { enabled = false },
        panel = { enabled = false },
      }
    end,
  },
  {
    -- INFO: This is for nvim-cmp compatibility with blink.cmp
    -- https://github.com/Saghen/blink.compat
    'saghen/blink.compat',
    -- use the latest release, via version = '*', if you also use the latest release for blink.cmp
    version = '*',
    -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
    lazy = true,
    -- make sure to set opts so that lazy.nvim calls blink.compat's setup
    opts = {},
  },
  {
    {
      -- INFO: https://github.com/Saghen/blink.cmp
      -- https://cmp.saghen.dev/ - documentation
      'saghen/blink.cmp',
      lazy = false,
      dependencies = {
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
        { 'L3MON4D3/LuaSnip', version = 'v2.*' },
        { 'Zeioth/NormalSnippets' },
        { 'benfowler/telescope-luasnip.nvim' },
        { 'giuxtaposition/blink-cmp-copilot' },
        { 'saadparwaiz1/cmp_luasnip' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-path' },
        -- 'Zeioth/NormalSnippets',
        -- 'benfowler/telescope-luasnip.nvim',
        { 'hrsh7th/cmp-buffer' },
      },
      version = '*',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        completion = {
          documentation = {
            auto_show = true,
            window = { border = 'single' },
          },
          menu = {
            border = 'single',
            draw = {
              columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
            },
          },
        },
        signature = {
          enabled = true,
          window = { border = 'single' },
        },
        snippets = {
          preset = 'luasnip',
          expand = function(snippet)
            require('luasnip').lsp_expand(snippet)
          end,
          active = function(filter)
            if filter and filter.direction then
              return require('luasnip').jumpable(filter.direction)
            end
            return require('luasnip').in_snippet()
          end,
          jump = function(direction)
            require('luasnip').jump(direction)
          end,
        },
        keymap = { preset = 'super-tab' },
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = 'mono',
        },

        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot', 'lazydev', 'codecompanion' },
          providers = {
            lsp = { fallbacks = { 'lazydev' } },
            lazydev = {
              name = 'LazyDev',
              module = 'lazydev.integrations.blink',
            },
            copilot = {
              name = 'copilot',
              module = 'blink-cmp-copilot',
              score_offset = 100,
              async = true,
              transform_items = function(_, items)
                local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = 'Copilot'
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end
                return items
              end,
            },
            codecompanion = {
              name = 'CodeCompanion',
              module = 'codecompanion.providers.completion.blink',
              enabled = true,
            },
          },
        },
      },
      opts_extend = { 'sources.default' },
      appearance = {
        -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
        kind_icons = {
          Copilot = '',
          Text = '󰉿',
          Method = '󰊕',
          Function = '󰊕',
          Constructor = '󰒓',

          Field = '󰜢',
          Variable = '󰆦',
          Property = '󰖷',

          Class = '󱡠',
          Interface = '󱡠',
          Struct = '󱡠',
          Module = '󰅩',

          Unit = '󰪚',
          Value = '󰦨',
          Enum = '󰦨',
          EnumMember = '󰦨',

          Keyword = '󰻾',
          Constant = '󰏿',

          Snippet = '󱄽',
          Color = '󰏘',
          File = '󰈔',
          Reference = '󰬲',
          Folder = '󰉋',
          Event = '󱐋',
          Operator = '󰪚',
          TypeParameter = '󰬛',
        },
      },
    },
  },
}
