return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      -- { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'j-hui/fidget.nvim', {} },
      -- { 'hrsh7th/cmp-nvim-lsp' },
      { 'antosha417/nvim-lsp-file-operations', config = true },
      -- { 'folke/neodev.nvim', opts = {} },
      { 'saghen/blink.cmp' },
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local mason_lspconfig = require 'mason-lspconfig'
      -- local cmp_nvim_lsp = require 'cmp_nvim_lsp'
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- Simply put, this is an easier way to create keymaps. Self-explanatory.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      ---@class lsp.ClientCapabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities = vim.tbl_deep_extend('force', capabilities, require('blink.cmp').get_lsp_capabilities())
      capabilities.offsetEncoding = { 'utf-16' }

      -- Default handlers for LSP servers
      mason_lspconfig.setup_handlers {
        function(server_name)
          lspconfig[server_name].setup {
            capabilities = capabilities,
          }
        end,
        lspconfig['lua_ls'].setup {
          capabilities = capabilities,
          settings = {
            Lua = {
              diagnostics = {
                globals = { 'vim' },
              },
            },
          },
        },
        lspconfig['ruff'].setup {
          capabilities = capabilities,
          init_options = {
            settings = {
              -- TODO: Add ruff settings
              -- configuration = "/path/to/ruff.toml",

              -- Line length for formatting
              lineLength = 200,
              -- Organize imports on save
              organizeImports = true,
              -- Show syntax errors
              showSyntaxErrors = true,
              -- Log level
              logLevel = 'info',
              fixAll = true,
              codeAction = {
                lint = {
                  enable = true,
                  preview = true,
                },
              },
            },
          },
        },
      }

      -- lspconfig.lua_ls.setup {
      --   capabilities = capabilities,
      -- }
      -- lspconfig.clangd.setup {
      --   capabilities = capabilities,
      --   init_options = {
      --     clangdFileStatus = true,
      --     clangTidy = {
      --       checks = { '*' },
      --     },
      --   },
      -- }
      -- -- lspconfig.pyright.setup {
      -- --   capabilities = capabilities,
      -- -- }
      -- lspconfig.ruff.setup {
      --   capabilities = capabilities,
      --   init_options = {
      --     settings = {
      --       lineLength = 120,
      --       organizeImports = true,
      --       showSyntaxErrors = true,
      --       line = {
      --         enable = true,
      --       },
      --       format = {
      --         enable = true,
      --       },
      --     },
      --   },
      -- }
      -- lspconfig.bashls.setup {
      --   capabilities = capabilities,
      -- }
      -- lspconfig.ts_ls.setup {
      --   capabilities = capabilities,
      -- }
      -- lspconfig.html.setup {
      --   capabilities = capabilities,
      -- }
    end,
  },
}
