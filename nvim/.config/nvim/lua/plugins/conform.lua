return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre', 'BufNewFile' },
  cmd = { 'ConformInfo' },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = {} -- example: cpp = true
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
        async = false,
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { 'isort', 'black' },
      python = {
        -- 'ruff_format',
        -- To fix auto-fixable lint errors.
        -- 'ruff_fix',
        -- To run the Ruff formatter.
        'ruff_format',
        'ruff_check',
        -- To organize the imports.
        'ruff_organize_imports',
      },
      html = { 'prettierd' },
      sh = { 'shfmt' },
      json = { 'prettierd' },
      svelte = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      markdown = { 'prettierd' },
      yaml = { 'prettierd' },
      toml = { 'prettierd' },
      tyoeScript = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      --
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
