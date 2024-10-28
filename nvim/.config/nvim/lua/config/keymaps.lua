local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- Neotree Keymaps
map('n', '<leader>e', ':Neotree filesystem reveal left<CR>', { desc = 'Fil[E] System Reveal' })

-- local builtin = require('telescope.builtin')
-- map('n', '<leader>ff', ':Telescope find_files<CR>', {})
-- vim.keymap.set('n', '<leader>ff', builtin.find_files,  { desc = '[F]ind [F]files' })
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind [G]rep' })

-- LSP Keymaps
-- vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
-- vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
-- vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})

-- Clear highlights on search when pressing <esc> in normal mode
-- :help hlsearch
map('n', '<Esc>', '<cmd>nohlsearch<CR>', {})

-- Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Keymaps for the Debugger
local dap = require('dap')
vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<leader>dc', dap.continue, {})

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
