return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'j-hui/fidget.nvim', {} },
      { 'antosha417/nvim-lsp-file-operations', config = true },
      { 'saghen/blink.cmp' },
    },
    config = function()
      -- Set up LSP attach autocommand (this part stays the same)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Note: LSP keymaps are centralized in lua/core/keymaps.lua
          -- Only buffer-specific logic remains here

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- Configure LSP servers using vim.lsp.config() for Neovim 0.11+

      -- Lua Language Server
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
          },
        },
      })

      -- Clangd for C/C++
      vim.lsp.config('clangd', {
        cmd = { 'clangd', '--background-index', '--clang-tidy', '--log=verbose', '--completion-style=detailed' },
      })

      -- Ruff for Python
      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            lineLength = 200,
            organizeImports = true,
            showSyntaxErrors = true,
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
      })

      -- SourceKit LSP for Swift
      vim.lsp.config('sourcekit', {
        cmd = { 'sourcekit-lsp' },
        root_markers = { 'Package.swift', '.git' },
      })

      -- Enable the LSP servers
      vim.lsp.enable 'lua_ls'
      vim.lsp.enable 'clangd'
      vim.lsp.enable 'ruff'
      vim.lsp.enable 'sourcekit'
    end,
  },
}
