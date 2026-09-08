vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false
vim.opt.scrolloff = 8

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.clipboard:append("unnamedplus")

vim.opt.showmode = false

vim.opt.termguicolors = true

-- Default border for every floating window: blink's completion menu and docs,
-- LSP hover, diagnostic floats. Plugins that pass their own border still win.
-- Must be set before the plugins read it, which init.lua's first require does.
vim.o.winborder = "rounded"
