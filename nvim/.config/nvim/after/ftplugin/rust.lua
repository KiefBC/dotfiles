local map = vim.keymap.set

local opts = {
	buffer = true,
	silent = true,
	desc = "Rust Code Actions",
}

map("n", "<leader>ca", function()
	vim.cmd.RustLsp("codeAction")
end, opts)

map("x", "<leader>ca", ":RustLsp codeAction<CR>", opts)
