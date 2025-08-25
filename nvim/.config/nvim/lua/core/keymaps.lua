local keymap = vim.keymap -- Alias to make it easier to use

-- ===================================================================
-- CORE VIM KEYMAPS
-- ===================================================================

-- Some Keymaps I use:
-- <\> opens the file tree
-- <K> shows the hover property
-- <Esc> clears the search highlights
-- <leader>q opens the diagnostic quickfix list
-- <Esc><Esc> exits terminal mode

-- Window management
keymap.set('n', '<leader>bsv', ':vsplit<CR>', { desc = 'Buffer [S]plit [V]ertically' })
keymap.set('n', '<leader>bsh', ':split<CR>', { desc = 'Buffer [S]plit [H]orizontally' })
keymap.set('n', '<leader>bse', ':wincmd =<CR>', { desc = 'Buffer [S]plit [E]qual' })
keymap.set('n', '<leader>bsx', '<cmd>close<CR>', { desc = 'Buffer [S]plit [X] Close' })

-- Tab management
keymap.set('n', '<leader>to', ':tabnew<CR>', { desc = '[T]ab [O]pen' })
keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = '[T]ab [C]lose' })
keymap.set('n', '<leader>tn', ':tabnext<CR>', { desc = '[T]ab [N]ext' })
keymap.set('n', '<leader>tp', ':tabprevious<CR>', { desc = '[T]ab [P]revious' })

-- LSP hover
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

-- ===================================================================
-- FILE EXPLORER (Neo-tree)
-- ===================================================================

keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal', silent = true })
keymap.set('n', '<leader>e', ':Neotree filesystem reveal left<CR>', { desc = 'Fil[E] Tree' })

-- ===================================================================
-- FUZZY FINDING (fzf-lua)
-- ===================================================================

keymap.set('n', '<leader>sf', function()
  require('fzf-lua').files { cwd = vim.uv.cwd() }
end, { desc = 'Search [F]iles' })

keymap.set('n', '<leader>sb', function()
  require('fzf-lua').buffers {}
end, { desc = 'Search [B]uffers' })

keymap.set('n', '<leader>sg', function()
  require('fzf-lua').live_grep {}
end, { desc = 'Search [G]rep' })

-- ===================================================================
-- FUZZY FINDING (Telescope)
-- ===================================================================

keymap.set('n', '<leader>sh', function()
  require('telescope.builtin').help_tags()
end, { desc = '[S]earch [H]elp' })

keymap.set('n', '<leader>sk', function()
  require('telescope.builtin').keymaps()
end, { desc = '[S]earch [K]eymaps' })

keymap.set('n', '<leader>ss', function()
  require('telescope.builtin').builtin()
end, { desc = '[S]earch [S]elect Telescope' })

keymap.set('n', '<leader>sw', function()
  require('telescope.builtin').grep_string()
end, { desc = '[S]earch current [W]ord' })

keymap.set('n', '<leader>sd', function()
  require('telescope.builtin').diagnostics()
end, { desc = '[S]earch [D]iagnostics' })

keymap.set('n', '<leader>sr', function()
  require('telescope.builtin').resume()
end, { desc = '[S]earch [R]esume' })

keymap.set('n', '<leader>s.', function()
  require('telescope.builtin').oldfiles()
end, { desc = '[S]earch Recent Files ("." for repeat)' })

keymap.set('n', '<leader><leader>', function()
  require('telescope.builtin').buffers()
end, { desc = '[ ] Find existing buffers' })

keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

keymap.set('n', '<leader>s/', function()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

keymap.set('n', '<leader>sn', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- ===================================================================
-- LSP NAVIGATION AND ACTIONS (Telescope)
-- ===================================================================

keymap.set('n', 'gd', function()
  require('telescope.builtin').lsp_definitions()
end, { desc = 'Go to [D]efinition' })

keymap.set('n', 'gr', function()
  require('telescope.builtin').lsp_references()
end, { desc = 'Find [R]eferences' })

keymap.set('n', 'gI', function()
  require('telescope.builtin').lsp_implementations()
end, { desc = 'Go to [I]mplementation' })

keymap.set('n', '<leader>D', function()
  require('telescope.builtin').lsp_type_definitions()
end, { desc = 'Type [D]efinition' })

keymap.set('n', '<leader>ds', function()
  require('telescope.builtin').lsp_document_symbols()
end, { desc = '[D]ocument [S]ymbols' })

keymap.set('n', '<leader>ws', function()
  require('telescope.builtin').lsp_workspace_symbols()
end, { desc = '[W]orkspace [S]ymbols' })

-- ===================================================================
-- TODO COMMENTS (Telescope integration)
-- ===================================================================

keymap.set('n', ']t', function()
  require('todo-comments').jump_next()
end, { desc = 'Jump to next todo' })

keymap.set('n', '[t', function()
  require('todo-comments').jump_prev()
end, { desc = 'Jump to previous todo' })

-- ===================================================================
-- INLAY HINTS (LSP)
-- ===================================================================

if vim.client and vim.client.supports_method 'textDocument/inlayHint' then
  keymap.set('n', '<leader>th', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { desc = '[T]oggle Inlay [H]ints' })
end

-- ===================================================================
-- GIT OPERATIONS (Gitsigns)
-- ===================================================================

-- Function to set up Git keymaps when Gitsigns attaches to a buffer
local function setup_git_keymaps(bufnr)
  local gitsigns = require 'gitsigns'

  local function map(mode, l, r, opts)
    opts = opts or {}
    opts.buffer = bufnr
    keymap.set(mode, l, r, opts)
  end

  -- Navigation
  map('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal { ']c', bang = true }
    else
      gitsigns.nav_hunk 'next'
    end
  end, { desc = 'Jump to next git [c]hange' })

  map('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal { '[c', bang = true }
    else
      gitsigns.nav_hunk 'prev'
    end
  end, { desc = 'Jump to previous git [c]hange' })

  -- Actions
  -- visual mode
  map('v', '<leader>hs', function()
    gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'stage git hunk' })
  map('v', '<leader>hr', function()
    gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'reset git hunk' })
  -- normal mode
  map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
  map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
  map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
  map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'git [u]ndo stage hunk' })
  map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
  map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
  map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
  map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
  map('n', '<leader>hD', function()
    gitsigns.diffthis '@'
  end, { desc = 'git [D]iff against last commit' })
  -- Toggles
  map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
  map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle git show [D]eleted' })
end

-- Export the function so it can be used by gitsigns configuration
_G.setup_git_keymaps = setup_git_keymaps

-- ===================================================================
-- CODE FORMATTING (Conform)
-- ===================================================================

keymap.set('', '<leader>f', function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end, { desc = '[F]ormat Buffer' })

keymap.set('v', '<leader>f', function()
  require('conform').format {
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  }
end, { desc = '[F]ormat selection' })

-- ===================================================================
-- DEBUGGING (DAP)
-- ===================================================================

keymap.set('n', '<F5>', function()
  require('dap').continue()
end, { desc = 'Debug: Start/Continue' })

keymap.set('n', '<F1>', function()
  require('dap').step_into()
end, { desc = 'Debug: Step Into' })

keymap.set('n', '<F2>', function()
  require('dap').step_over()
end, { desc = 'Debug: Step Over' })

keymap.set('n', '<F3>', function()
  require('dap').step_out()
end, { desc = 'Debug: Step Out' })

keymap.set('n', '<leader>b', function()
  require('dap').toggle_breakpoint()
end, { desc = 'Debug: Toggle Breakpoint' })

keymap.set('n', '<leader>B', function()
  require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
end, { desc = 'Debug: Set Breakpoint' })

keymap.set('n', '<F7>', function()
  require('dapui').toggle()
end, { desc = 'Debug: See last session result.' })

-- ===================================================================
-- DIAGNOSTICS (Trouble)
-- ===================================================================

keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>', { desc = 'Symbols (Trouble)' })
keymap.set('n', '<leader>xl', '<cmd>Trouble lsp toggle focus=false win.position=right<cr>', { desc = 'LSP Definitions / references / ... (Trouble)' })
keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })

-- ===================================================================
-- UTILITIES (Snacks)
-- ===================================================================

keymap.set('n', '<leader>.', function()
  require('snacks').scratch()
end, { desc = 'Toggle [S]cratch Buffer' })

keymap.set('n', '<leader>S', function()
  require('snacks').scratch.select()
end, { desc = 'Select [S]cratch Buffer' })

keymap.set('n', '<leader>lg', function()
  require('snacks').lazygit()
end, { desc = 'Lazy [G]it' })

keymap.set('n', '<leader>n', function()
  require('snacks').notifier.show_history()
end, { desc = '[N]otification History' })

keymap.set('n', '<leader>un', function()
  require('snacks').notifier.hide()
end, { desc = 'Dismiss All Notifications' })

-- ===================================================================
-- TREESITTER TEXT OBJECTS (Repeatable moves)
-- ===================================================================

-- Note: These require treesitter-textobjects to be loaded first
vim.defer_fn(function()
  local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
  
  -- Vim way: ; goes to the direction you were moving.
  keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
  keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)
  
  -- Make builtin f, F, t, T also repeatable with ; and ,
  keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f)
  keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F)
  keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t)
  keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T)
end, 100)
