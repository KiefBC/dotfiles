require("config.options")
-- Keysmaps need to be loaded AFTER some of my plugins to work correctly

-- This needs to be set BEFORE we vim.pack.add
vim.g.rustaceanvim = {
	tools = {
		code_actions = {
			-- Use the normal picker when rust-analyzer returns
			-- ordinary, non-grouped actions.
			ui_select_fallback = true,
		},
	},
}

vim.pack.add({
	-- LSPs
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- Themes
	{ src = "https://github.com/eldritch-theme/eldritch.nvim" },

	-- Blinks
	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/Saghen/blink.cmp" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{
		src = "https://github.com/Saghen/blink.pairs",
		version = vim.version.range("*"),
	},

	-- Folke
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{
		src = "https://github.com/folke/trouble.nvim",
		version = vim.version.range("^3"),
	},

	-- Treesitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },

	-- Rust specific
	{
		src = "https://github.com/mrcjkb/rustaceanvim",
		version = vim.version.range("^9"),
	},
	{
		src = "https://github.com/saecki/crates.nvim",
		version = vim.version.range("*"),
	},

	{
		src = "https://github.com/stevearc/conform.nvim",
		version = vim.version.range("^9"),
	},

	-- Debugging
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },

	-- Git
	{ src = "https://github.com/NeogitOrg/neogit" },
	{ src = "https://github.com/esmuellert/codediff.nvim" },
	{
		src = "https://github.com/lewis6991/gitsigns.nvim",
		version = vim.version.range("^2"),
	},

	-- Diagnostics and TODOs
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{
		src = "https://github.com/folke/trouble.nvim",
		version = vim.version.range("^3"),
	},

	{ src = "https://github.com/nvim-lualine/lualine.nvim" },

	{
		src = "https://github.com/kylechui/nvim-surround",
		version = vim.version.range("4.x"),
	},
	{
		src = "https://github.com/OXY2DEV/markview.nvim",
		version = vim.version.range("^28"),
	},
	{
		src = "https://github.com/stevearc/overseer.nvim",
		version = vim.version.range("^2"),
	},
	{ src = "https://github.com/catgoose/nvim-colorizer.lua" },
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
})

require("tiny-inline-diagnostic").setup({
	preset = "ghost",

	options = {
		multilines = {
			enabled = true,
		},
	},
})

vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = false,
})

require("colorizer").setup({
	filetypes = {
		"css",
		"scss",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
		"vue",
	},
	options = {
		parsers = {
			css = true,
			tailwind = {
				enable = true,
				lsp = true,
			},
		},
		display = {
			mode = "virtualtext",
			virtualtext = {
				char = "■",
				position = "after",
			},
			disable_document_color = true,
		},
	},
})

require("overseer").setup({
	dap = true,

	task_list = {
		direction = "bottom",
		min_height = 10,
		max_height = 20,
	},
})

-- TODO comments
require("todo-comments").setup({})

-- Trouble
require("trouble").setup({
	modes = {
		preview_float = {
			mode = "diagnostics",

			preview = {
				type = "float",
				relative = "editor",
				border = "rounded",
				title = "Preview",
				title_pos = "center",
				position = { 0, -2 },
				size = {
					width = 0.3,
					height = 0.3,
				},
				zindex = 200,
			},
		},
	},
})

-- Which-Key
local wk = require("which-key")
wk.setup({
	preset = "modern",
	delay = 200,
})
wk.add({
	{ "<leader>u", group = "Toggle" },
	{ "<leader>s", group = "Search" },
	{ "<leader>g", group = "Git" },
	{ "<leader>b", group = "Buffer" },
	{ "<leader>d", group = "Debug" },
	{ "<leader>h", group = "Git Hunks" },
	{ "<leader>x", group = "Trouble" },
	{ "<leader>o", group = "Tasks" },
})

-- Theme
vim.cmd.colorscheme("eldritch")

-- LSP
require("mason").setup()
require("eldritch").setup()
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
})

require("mason-lspconfig").setup({
	ensure_installed = {
		"lua_ls",
		"gopls",
		"clangd",
		"ruff",
		"ty",
		"tailwindcss",
	},

	automatic_enable = {
		exclude = {
			"rust_analyzer",
		},
	},
})

require("mason-tool-installer").setup({
	ensure_installed = {
		"stylua",
		"goimports",
		"clang-format",
		"sqruff",
		"prettierd",
		"prettier",
		"shfmt",
		"taplo",

		-- Debug adapters
		"codelldb", -- Rust, C and C++
		"delve", -- Go
		"debugpy", -- Python

		"mmdc", -- Mermaid diagram rendering
	},

	auto_update = false,
	run_on_start = true,
	start_delay = 1000,
	debounce_hours = 24,

	integrations = {
		["mason-lspconfig"] = true,
		["mason-null-ls"] = false,
		["mason-nvim-dap"] = false,
	},
})

-- Blink
local blink = require("blink.cmp")
blink.build():pwait()
blink.setup({
	keymap = {
		preset = "enter",
	},

	appearance = {
		nerd_font_variant = "mono",
	},

	-- The menu and documentation windows take their border from
	-- vim.o.winborder (set in config/options.lua); without it they default to
	-- `padded`, which is blank cells and shows no edge at all.
	completion = {
		documentation = {
			auto_show = true,
		},
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},

	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})

local blink_pairs = require("blink.pairs")

blink_pairs.download():pwait(60000)
blink_pairs.setup()

-- Snacks
require("snacks").setup({
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
		},
	},
	explorer = { enabled = true },
	picker = { enabled = true },
	statuscolumn = { enabled = true },
	animate = { enabled = true },
	terminal = { enabled = true },
	input = { enabled = true },
	keymap = { enabled = true },
	image = { enabled = true },
	gh = { enabled = true },
	git = { enabled = true },
	indent = { enabled = true },
	lazygit = { enabled = true },

	toggle = {
		enabled = true,
		which_key = true,
		notify = true,
	},

	notifier = {
		enabled = true,
		timeout = 3000,
		style = "compact",
	},
})

-- Crates
require("crates").setup({
	lsp = {
		enabled = true,
		actions = true,
		completion = true,
		hover = true,
	},

	completion = {
		crates = {
			enabled = true,
			min_chars = 3,
			max_results = 8,
		},
	},

	popup = {
		border = "rounded",
	},
})

-- Noice
require("noice").setup({
	cmdline = {
		enabled = true,
		view = "cmdline_popup",
	},

	messages = {
		enabled = true,
		view = "mini",
		view_error = "notify",
		view_warn = "notify",
		view_history = "messages",
		view_search = "virtualtext",
	},

	popupmenu = {
		enabled = false,
	},

	-- Let Snacks own vim.notify().
	notify = {
		enabled = false,
	},

	lsp = {
		progress = { enabled = false },
		hover = { enabled = false },
		signature = { enabled = false },
	},

	routes = {
		{
			filter = {
				event = "msg_show",
				find = "written",
			},
			view = "notify",
		},
	},
})

-- Treesitter
require("nvim-treesitter").install({
	"bash",
	"cpp",
	"css",
	"go",
	"html",
	"javascript",
	"latex",
	"norg",
	"python",
	"regex",
	"rust",
	"scss",
	"svelte",
	"tsx",
	"typescript",
	"typst",
	"vue",

	"markdown",
	"markdown_inline",
	"yaml", -- optional, for frontmatter
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"sh",
		"cpp",
		"go",
		"python",
		"rust",
		"typescript",
	},

	callback = function(args)
		vim.treesitter.start(args.buf)

		-- Syntax-aware folding
		vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo[0][0].foldmethod = "expr"

		-- Keep everything open when entering the file
		vim.wo[0][0].foldlevel = 99
	end,
})

require("markview").setup({
	preview = {
		icon_provider = "mini",
		enable_hybrid_mode = true,
	},
})

-- Conform
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },

		python = {
			"ruff_fix",
			-- "ruff_organize_imports",
			"ruff_format",
		},

		rust = { "rustfmt" },
		go = { "goimports", "gofmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sql = { "sqruff" },
		html = { "prettierd" },
		sh = { "shfmt" },
		json = { "prettierd" },
		svelte = { "prettierd" },
		css = { "prettierd" },
		scss = { "prettierd" },
		markdown = { "prettier" },
		yaml = { "prettierd" },
		toml = { "taplo" },
		typescript = { "prettierd" },
		typescriptreact = { "prettierd" },
		javascript = { "prettierd" },
		javascriptreact = { "prettierd" },
	},

	default_format_opts = {
		lsp_format = "fallback",
	},

	format_on_save = function(bufnr)
		-- This only disables LSP fallback for these filetypes.
		-- Configured external formatters will still run.
		local disable_lsp_fallback = {
			-- cpp = true,
		}

		return {
			timeout_ms = 2000,
			lsp_format = disable_lsp_fallback[vim.bo[bufnr].filetype] and "never" or "fallback",
		}
	end,

	notify_on_error = true,
	notify_no_formatters = false,
})

-- Git signs
require("gitsigns").setup({
	current_line_blame = false,

	current_line_blame_opts = {
		delay = 300,
		virt_text_pos = "eol",
	},

	preview_config = {
		border = "rounded",
	},
})

-- CodeDiff
require("codediff").setup({
	diff = {
		layout = "side-by-side",
		disable_inlay_hints = true,
	},
})

-- Neogit
require("neogit").setup({
	integrations = {
		snacks = true,
		diffview = false,
		codediff = true,
	},

	diff_viewer = "codediff",
})

-- Lualine
local trouble = require("trouble")

local symbols = trouble.statusline({
	mode = "lsp_document_symbols",
	groups = {},
	title = false,
	filter = {
		range = true,
	},
	format = "{kind_icon}{symbol.name:Normal}",
})

local function gitsigns_diff()
	local status = vim.b.gitsigns_status_dict

	if not status then
		return nil
	end

	return {
		added = status.added,
		modified = status.changed,
		removed = status.removed,
	}
end

require("lualine").setup({
	options = {
		theme = "eldritch",
		globalstatus = true,

		component_separators = {
			left = "│",
			right = "│",
		},

		section_separators = {
			left = "",
			right = "",
		},

		disabled_filetypes = {
			statusline = {
				"snacks_dashboard",
			},
		},
	},

	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(mode)
					return mode:sub(1, 3)
				end,
			},
		},

		lualine_b = {
			"branch",
			{
				"diff",
				source = gitsigns_diff,
				symbols = {
					added = " ",
					modified = " ",
					removed = " ",
				},
			},
		},

		lualine_c = {
			{
				"filename",
				path = 1,
				symbols = {
					modified = " ●",
					readonly = " ",
					unnamed = "[No Name]",
					newfile = "[New]",
				},
			},
			{
				symbols.get,
				cond = symbols.has,
			},
		},

		lualine_x = {
			{
				"diagnostics",
				sources = {
					"nvim_diagnostic",
				},
				symbols = {
					error = " ",
					warn = " ",
					info = " ",
					hint = "󰌵 ",
				},
			},
			"lsp_status",
			"filetype",
		},

		lualine_y = {
			"progress",
		},

		lualine_z = {
			"location",
		},
	},

	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {
			{
				"filename",
				path = 1,
			},
		},
		lualine_x = {
			"location",
		},
		lualine_y = {},
		lualine_z = {},
	},

	extensions = {
		"trouble",
		"nvim-dap-ui",
		"quickfix",
	},
})

require("config.debug")
require("config.keymaps")
