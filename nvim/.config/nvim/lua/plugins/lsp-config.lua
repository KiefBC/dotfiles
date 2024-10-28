return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
		--config = function()
		-- require("mason-lspconfig").setup({
		-- ensure_installed = { "lua_ls", "ts_ls" },
		--})
		--end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Detect architecture and set clangd command accordingly
			local clangd_cmd = "clangd"
			if vim.loop.os_uname().machine == "aarch64" then
				clangd_cmd = "clangd-15"
			end

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
				-- cmd = { "clangd-15" },
				cmd = { clangd_cmd },
			})
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.eslint.setup({
				capabilities = capabilities,
			})
		end,
	},
}
