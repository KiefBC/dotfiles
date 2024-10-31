local keymap = vim.keymap -- Alias to make it easier to use

-- Some Keymaps I use:
-- <\> opens the file tree
-- <K> shows the hover property
-- <Esc> clears the search highlights
-- <leader>q opens the diagnostic quickfix list
-- <Esc><Esc> exits terminal mode

-- These will help with splitting the windows
keymap.set('n', '<leader>sv', ':vsplit<CR>', { desc = '[S]plit [V]ertically' })
keymap.set('n', '<leader>sh', ':split<CR>', { desc = '[S]plit [H]orizontally' })
keymap.set('n', '<leader>se', ':wincmd =<CR>', { desc = '[S]plit [E]qual' })
keymap.set('n', '<leader>sx', '<cmd>close<CR>', { desc = '[S]plit [X] Close' })

-- This will show us the Directory Strcuture
keymap.set('n', '<leader>e', ':Neotree filesystem reveal left<CR>', { desc = 'Fil[E] Tree' })
-- This will allow us to Shift-K and get the Hover property to show
keymap.set('n', 'K', vim.lsp.buf.hover, {})

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
