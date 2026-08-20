local dap = require("dap")
local dapui = require("dapui")

-- Debugger UI
dapui.setup({
	floating = {
		border = "rounded",
	},
})

-- Automatically manage the debugger UI.
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

-- Breakpoint signs
vim.fn.sign_define("DapBreakpoint", {
	text = "●",
	texthl = "DiagnosticError",
})

vim.fn.sign_define("DapBreakpointCondition", {
	text = "◆",
	texthl = "DiagnosticWarn",
})

vim.fn.sign_define("DapStopped", {
	text = "▶",
	texthl = "DiagnosticInfo",
	linehl = "Visual",
})

-- Go: Delve adapter and test configurations.
require("dap-go").setup()

-- Python: debugpy installed through Mason.
local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

require("dap-python").setup(debugpy_python)

-- C and C++: codelldb installed through Mason.
dap.adapters.codelldb = {
	type = "server",
	port = "${port}",

	executable = {
		command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
		args = { "--port", "${port}" },
	},
}

local codelldb_launch = {
	name = "Launch executable",
	type = "codelldb",
	request = "launch",

	program = function()
		return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	end,

	cwd = "${workspaceFolder}",
	stopOnEntry = false,
}

local codelldb_attach = {
	name = "Attach to process",
	type = "codelldb",
	request = "attach",
	pid = require("dap.utils").pick_process,
	cwd = "${workspaceFolder}",
}

dap.configurations.c = {
	codelldb_launch,
	codelldb_attach,
}

dap.configurations.cpp = {
	vim.deepcopy(codelldb_launch),
	vim.deepcopy(codelldb_attach),
}

-- Do not configure dap.configurations.rust here.
-- Rustaceanvim owns Rust debugging.
