vim.g.mapleader = " "

local map = vim.keymap.set

-- Disable the constant search highlighting
map("n", "<Esc>", "<cmd>nohlsearch<CR>", {
	desc = "Clear Search Highlight",
})

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move Focus to the Left Window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move Focus to the Right Window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move Focus to the Lower Window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move Focus to the Upper Window" })

-- == Convienence Keys ==
map("n", "<leader>r", function()
	package.loaded["config.options"] = nil
	package.loaded["config.keymaps"] = nil

	require("config.options")
	require("config.keymaps")

	vim.notify("Configuration reloaded")
end, {
	desc = "Reload configuration",
})

-- Formatting
map("n", "<leader>f", function()
	require("conform").format({
		async = false,
		timeout_ms = 2000,
		lsp_format = "fallback",
	})
end, {
	desc = "Format Buffer",
})

-- == Snacks ==
map("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "File Explorer" })

-- Misc
map("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Keymaps" })
map({ "n", "t" }, "]]", function()
	Snacks.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
map({ "n", "t" }, "[[", function()
	Snacks.words.jump(-vim.v.count1)
end, { desc = "Previous Reference" })
map("n", "<leader>cR", function()
	Snacks.rename.rename_file()
end, { desc = "Rename File" })
map("n", "<leader>uC", function()
	Snacks.picker.colorschemes()
end, { desc = "Colorschemes" })

-- Find/Search/Buffers
map("n", "<leader><leader>", function()
	Snacks.picker.buffers()
end, { desc = "Search Open Buffers" })
map("n", "<leader>sg", function()
	Snacks.picker.grep()
end, { desc = "Grep Buffers" })
map("n", "<leader>s/", function()
	Snacks.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })
map("n", "<leader>sd", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Search Buffer Diagnostics" })
map("n", "<leader>bd", function()
	Snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>sf", function()
	Snacks.picker.files()
end, { desc = "Search Files" })

-- Git
map("n", "<leader>lg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
map("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git Branches" })
map("n", "<leader>gl", function()
	Snacks.picker.git_log()
end, { desc = "Git Log" })
map("n", "<leader>gL", function()
	Snacks.picker.git_log_line()
end, { desc = "Git Log Line" })
map("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git Status" })
map("n", "<leader>gS", function()
	Snacks.picker.git_stash()
end, { desc = "Git Stash" })
map("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })
map("n", "<leader>gf", function()
	Snacks.picker.git_log_file()
end, { desc = "Git Log File" })

-- Github
map("n", "<leader>gi", function()
	Snacks.picker.gh_issue()
end, { desc = "GitHub Issues (open)" })
map("n", "<leader>gI", function()
	Snacks.picker.gh_issue({ state = "all" })
end, { desc = "GitHub Issues (all)" })
map("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
map("n", "<leader>gP", function()
	Snacks.picker.gh_pr({ state = "all" })
end, { desc = "GitHub Pull Requests (all)" })

-- Terminal
map("n", "<leader>/", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })
map("n", "<C-_>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })

-- Notifications
map("n", "<leader>n", function()
	Snacks.notifier.show_history()
end, { desc = "Notification History" })
map("n", "<leader>un", function()
	Snacks.notifier.hide()
end, { desc = "Dismiss All Notifications" })

-- Toggle
-- Only Snacks Toggle can use these :map("...") settings
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.animate():map("<leader>ua")

-- Crate specific keymaps
local crates = require("crates")

map("n", "<leader>cp", crates.show_popup, {
	desc = "Crate Information",
})

map("n", "<leader>cv", crates.show_versions_popup, {
	desc = "Crate Versions",
})

map("n", "<leader>cf", crates.show_features_popup, {
	desc = "Crate Features",
})

map("n", "<leader>cd", crates.show_dependencies_popup, {
	desc = "Crate Dependencies",
})

map("n", "<leader>cu", crates.update_crate, {
	desc = "Update Crate",
})

map("n", "<leader>cU", crates.upgrade_crate, {
	desc = "Upgrade Crate",
})

map("n", "<leader>cX", crates.update_all_crates, {
	desc = "Update All Crates",
})

map("n", "<leader>cA", crates.upgrade_all_crates, {
	desc = "Upgrade All Crates",
})

map("n", "<leader>cD", crates.open_documentation, {
	desc = "Open Crate Documentation",
})

-- == Debugging ==
local dap = require("dap")
local dapui = require("dapui")

map("n", "<F5>", dap.continue, {
	desc = "Debug: Start/Continue",
})

map("n", "<F10>", dap.step_over, {
	desc = "Debug: Step Over",
})

map("n", "<F11>", dap.step_into, {
	desc = "Debug: Step Into",
})

map("n", "<S-F11>", dap.step_out, {
	desc = "Debug: Step Out",
})

map("n", "<leader>dc", dap.continue, {
	desc = "Start/Continue",
})

map("n", "<leader>db", dap.toggle_breakpoint, {
	desc = "Toggle Breakpoint",
})

map("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, {
	desc = "Conditional Breakpoint",
})

map("n", "<leader>do", dap.step_over, {
	desc = "Step Over",
})

map("n", "<leader>di", dap.step_into, {
	desc = "Step Into",
})

map("n", "<leader>dO", dap.step_out, {
	desc = "Step Out",
})

map("n", "<leader>dt", dap.terminate, {
	desc = "Terminate",
})

map("n", "<leader>dl", dap.run_last, {
	desc = "Run Last",
})

map("n", "<leader>dr", function()
	dap.repl.open()
end, {
	desc = "Open REPL",
})

map("n", "<leader>du", dapui.toggle, {
	desc = "Toggle Debug UI",
})

map({ "n", "v" }, "<leader>de", dapui.eval, {
	desc = "Evaluate Expression",
})

-- Rustaceanvim
map("n", "<leader>dd", function()
	vim.cmd.RustLsp("debug")
end, {
	desc = "Debug Rust Target",
})

map("n", "<leader>dR", function()
	vim.cmd.RustLsp("debuggables")
end, {
	desc = "Select Rust Debug Target",
})

-- Go
map("n", "<leader>dg", function()
	require("dap-go").debug_test()
end, {
	desc = "Debug Go Test",
})

-- Python
map("n", "<leader>dp", function()
	require("dap-python").test_method()
end, {
	desc = "Debug Python Test",
})

-- Git hunks
local gitsigns = require("gitsigns")

map("n", "]h", function()
	gitsigns.nav_hunk("next")
end, {
	desc = "Next Git Hunk",
})

map("n", "[h", function()
	gitsigns.nav_hunk("prev")
end, {
	desc = "Previous Git Hunk",
})

map("n", "<leader>hs", gitsigns.stage_hunk, {
	desc = "Stage Hunk",
})

map("v", "<leader>hs", function()
	gitsigns.stage_hunk({
		vim.fn.line("."),
		vim.fn.line("v"),
	})
end, {
	desc = "Stage Selected Hunk",
})

map("n", "<leader>hr", gitsigns.reset_hunk, {
	desc = "Reset Hunk",
})

map("v", "<leader>hr", function()
	gitsigns.reset_hunk({
		vim.fn.line("."),
		vim.fn.line("v"),
	})
end, {
	desc = "Reset Selected Hunk",
})

map("n", "<leader>hS", gitsigns.stage_buffer, {
	desc = "Stage Buffer",
})

map("n", "<leader>hR", gitsigns.reset_buffer, {
	desc = "Reset Buffer",
})

map("n", "<leader>hp", gitsigns.preview_hunk, {
	desc = "Preview Hunk",
})

map("n", "<leader>hi", gitsigns.preview_hunk_inline, {
	desc = "Preview Hunk Inline",
})

map("n", "<leader>hb", function()
	gitsigns.blame_line({ full = true })
end, {
	desc = "Blame Line",
})

map("n", "<leader>hB", gitsigns.toggle_current_line_blame, {
	desc = "Toggle Line Blame",
})

map("n", "<leader>hd", gitsigns.diffthis, {
	desc = "Diff Against Index",
})

map("n", "<leader>hD", function()
	gitsigns.diffthis("~")
end, {
	desc = "Diff Against Previous Commit",
})

map({ "o", "x" }, "ih", gitsigns.select_hunk, {
	desc = "Select Git Hunk",
})

local neogit = require("neogit")
map("n", "<leader>gg", function()
	neogit.open({
		kind = "tab",
	})
end, {
	desc = "Open Neogit",
})

map("n", "<leader>gD", "<cmd>CodeDiff<CR>", {
	desc = "Open Git Diff View",
})

map("n", "<leader>gh", "<cmd>CodeDiff history %<CR>", {
	desc = "Current File History",
})

-- Trouble
local trouble = require("trouble")

map("n", "<leader>xx", function()
	trouble.toggle("diagnostics")
end, {
	desc = "Workspace Diagnostics",
})

map("n", "<leader>xX", function()
	trouble.toggle({
		mode = "diagnostics",
		filter = { buf = 0 },
	})
end, {
	desc = "Buffer Diagnostics",
})

map("n", "<leader>xs", function()
	trouble.toggle({
		mode = "symbols",
		focus = false,
	})
end, {
	desc = "Document Symbols",
})

map("n", "<leader>xl", function()
	trouble.toggle({
		mode = "lsp",
		focus = false,
		win = {
			position = "right",
		},
	})
end, {
	desc = "LSP Definitions and References",
})

map("n", "<leader>xq", function()
	trouble.toggle("qflist")
end, {
	desc = "Quickfix List",
})

map("n", "<leader>xL", function()
	trouble.toggle("loclist")
end, {
	desc = "Location List",
})

map("n", "<leader>xp", function()
	trouble.toggle("preview_float")
end, {
	desc = "Diagnostics With Floating Preview",
})

map("n", "<leader>xt", function()
	trouble.toggle("todo")
end, {
	desc = "TODO Comments",
})

map("n", "]t", function()
	require("todo-comments").jump_next()
end, {
	desc = "Next TODO Comment",
})

map("n", "[t", function()
	require("todo-comments").jump_prev()
end, {
	desc = "Previous TODO Comment",
})

map("n", "<leader>um", "<cmd>Markview toggle<CR>", {
	desc = "Toggle Markdown Preview",
})

map("n", "<leader>mS", "<cmd>Markview splitToggle<CR>", {
	desc = "Toggle Markdown Split Preview",
})

-- Overseer
map("n", "<F6>", "<cmd>OverseerRun<CR>", {
	desc = "Run Project Task",
})

map("n", "<S-F6>", "<cmd>OverseerToggle<CR>", {
	desc = "Toggle Task List",
})

map("n", "<leader>or", "<cmd>OverseerRun<CR>", {
	desc = "Run Task",
})

map("n", "<leader>ot", "<cmd>OverseerToggle<CR>", {
	desc = "Toggle Tasks",
})

map("n", "<leader>ob", function()
	require("overseer").run_task({
		name = "just build",
		first = true,
	})
end, {
	desc = "Just Build",
})

map("n", "<leader>ot", function()
	require("overseer").run_task({
		name = "just test",
		first = true,
	})
end, {
	desc = "Just Test",
})

map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, {
	desc = "Code Actions",
})
