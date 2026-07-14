local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- Keys deliberately NOT mapped
-- ---------------------------------------------------------------------------
--
-- <Tab>  is the same byte as <C-i> (0x09), which is jump-forward in the
--        jumplist, the partner to <C-o>. Binding Tab to cycle buffers — as most
--        distros do — silently destroys <C-i>. Buffers are on [b / ]b instead.
-- <CR>   is the same byte as <C-m>. Same trap.
-- <C-s>  is signature help in insert mode (Neovim 0.11+ default).
-- <C-h/j/k/l>  left alone. tmux's root key-table is empty, so it never steals
--        these — but the shell and Claude Code want C-l and C-k, and split
--        navigation already has <C-w>hjkl. Crossing into a tmux pane is C-a hjkl.

-- ---------------------------------------------------------------------------
-- Increment / decrement — rehomed from <C-a>
-- ---------------------------------------------------------------------------
-- tmux owns <C-a> as its prefix, so Neovim can never see it. Its increment
-- command moves to +, and <C-x> follows it to - for symmetry. The keys they
-- displace (first non-blank of next/previous line) are no loss.

map({ 'n', 'v' }, '+', '<C-a>', { desc = 'Increment number' })
map({ 'n', 'v' }, '-', '<C-x>', { desc = 'Decrement number' })
map('v', 'g+', 'g<C-a>', { desc = 'Increment as sequence' })
map('v', 'g-', 'g<C-x>', { desc = 'Decrement as sequence' })

-- ---------------------------------------------------------------------------
-- The shared verbs — same letter as tmux, one scope inward
-- ---------------------------------------------------------------------------

map('n', '<leader>|', '<cmd>vsplit<cr>', { desc = 'Split right' })
map('n', '<leader>-', '<cmd>split<cr>', { desc = 'Split below' })

-- Close the buffer but keep the window open. Plain :bdelete would take the split
-- down with it.
map('n', '<leader>x', function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd('bprevious')
  pcall(vim.api.nvim_buf_delete, buf, {})
end, { desc = 'Close buffer' })

-- Maximise the current split, press again to restore the exact previous layout.
-- The tmux equivalent is C-a z.
map('n', '<leader>z', function()
  if vim.t.zoom_restore then
    vim.cmd(vim.t.zoom_restore)
    vim.t.zoom_restore = nil
  else
    local restore = vim.fn.winrestcmd()
    vim.cmd('wincmd _') -- max height
    vim.cmd('wincmd |') -- max width
    -- Unchanged layout means there was only one window; don't record a no-op.
    if vim.fn.winrestcmd() ~= restore then
      vim.t.zoom_restore = restore
    end
  end
end, { desc = 'Zoom split' })

map('n', '<leader>f', function() MiniPick.builtin.files() end, { desc = 'Find file' })

-- ---------------------------------------------------------------------------
-- Pickers and files
-- ---------------------------------------------------------------------------

map('n', '<leader>/', function() MiniPick.builtin.grep_live() end, { desc = 'Grep' })
map('n', '<leader>,', function() MiniPick.builtin.buffers() end, { desc = 'Buffers' })
map('n', '<leader>h', function() MiniPick.builtin.help() end, { desc = 'Help' })
map('n', '<leader>d', function() MiniExtra.pickers.diagnostic() end, { desc = 'Diagnostics' })
map('n', '<leader>k', function() MiniExtra.pickers.keymaps() end, { desc = 'Keymaps' })
map('n', '<leader>r', function() MiniPick.builtin.resume() end, { desc = 'Resume last pick' })

map('n', '<leader>e', function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end,
  { desc = 'Explorer (at current file)' })

map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Write' })

-- ---------------------------------------------------------------------------
-- Git — mirrors mini.clue's "+git" group
-- ---------------------------------------------------------------------------

local gs = function() return require('gitsigns') end
map('n', '<leader>gs', function() gs().stage_hunk() end, { desc = 'Stage hunk' })
map('n', '<leader>gr', function() gs().reset_hunk() end, { desc = 'Reset hunk' })
map('n', '<leader>gp', function() gs().preview_hunk() end, { desc = 'Preview hunk' })
map('n', '<leader>gb', function() gs().blame_line({ full = true }) end, { desc = 'Blame line' })
map('n', '<leader>gd', function() gs().diffthis() end, { desc = 'Diff this' })
map('n', ']h', function() gs().nav_hunk('next') end, { desc = 'Next hunk' })
map('n', '[h', function() gs().nav_hunk('prev') end, { desc = 'Prev hunk' })

-- ---------------------------------------------------------------------------
-- Buffers — on [b/]b precisely so <Tab> stays free (see the note at the top)
-- ---------------------------------------------------------------------------

map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev buffer' })

-- ---------------------------------------------------------------------------
-- Small comforts
-- ---------------------------------------------------------------------------

map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Leave terminal mode' })

-- Keep the cursor put while joining, and keep the view centred while jumping.
map('n', 'J', 'mzJ`z')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

-- Move the selection up and down, reindenting as it goes.
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Reindent without losing the selection.
map('v', '<', '<gv')
map('v', '>', '>gv')
