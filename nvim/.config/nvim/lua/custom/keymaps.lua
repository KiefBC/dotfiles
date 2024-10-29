-- This will show us the Directory Strcuture
vim.keymap.set('n', '<leader>e', ':Neotree filesystem reveal left<CR>', { desc = 'Fil[E] Tree' })
-- This will allow us to Shift-K and get the Hover property to show
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
