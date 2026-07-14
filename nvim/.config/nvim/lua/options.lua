local o = vim.o

-- Splits open where the mnemonic says they will: <leader>| to the right,
-- <leader>- below. Neovim's defaults are the opposite of both.
o.splitright = true
o.splitbelow = true

-- Wayland: routes yanks through wl-copy, the same clipboard tmux copies into.
o.clipboard = 'unnamedplus'

o.number = true
o.relativenumber = true
o.signcolumn = 'yes'          -- reserve the column, or text jumps when a sign appears
o.cursorline = true
o.wrap = false
o.scrolloff = 8
o.termguicolors = true
o.winborder = 'rounded'       -- 0.11+: one setting for every floating window

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 2
o.smartindent = true

o.ignorecase = true
o.smartcase = true            -- ...but a capital in the query makes it case-sensitive
o.inccommand = 'split'        -- live preview of :s///

o.undofile = true             -- undo survives closing the file
o.swapfile = false
o.updatetime = 250
o.timeoutlen = 400            -- how long mini.clue waits before showing the leader menu
o.confirm = true              -- prompt instead of failing on :q with unsaved changes

-- 'fuzzy' (0.11+) makes the built-in LSP completion menu tolerable without a
-- completion plugin. 'noselect' stops it from inserting a candidate you never chose.
o.completeopt = 'menu,menuone,noselect,fuzzy'
o.pumheight = 10

o.mouse = 'a'
o.laststatus = 3              -- one statusline for the whole editor, not per split
