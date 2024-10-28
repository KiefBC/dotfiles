-- Mapping our <leader> key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable mouse mode, good for resizing windows
vim.opt.mouse = "a"

-- Enable or Disable if using nerdfonts or not
vim.g.have_nerd_font = true

-- Show line numbers by default
vim.opt.number = true

-- When breakindent is enabled, wrapped lines will be visually indented 
-- to match the start of the original line, which helps make wrapped lines more readable 
-- by aligning them with the original line's indentation.
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive search unless \C or one or more capital letters
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250

-- Keep signcolum on by default
vim.opt.signcolumn = "yes"

-- How new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- TODO: Need to install Which-Key
-- Display the which-key popup sooner
vim.opt.timeoutlen = 300

-- Set how neovim will display certain whitepsace character in the editor
-- :help list
-- :help listchars
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview subsitions live, as you type
vim.opt.inccommand = "split"

-- Show which line the cursor is on
vim.opt.cursorline = true

-- Lines to show before moving
vim.opt.scrolloff = 10

-- Highlight when yankin (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
