-- Options only. Nothing here may `require` a plugin: this file runs before any pack
-- is on the runtimepath.

local opt = vim.opt

-- Leader: Space. tmux owns C-a and nothing else, so Space is invisible to it. It must
-- be set before any keymap is registered.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.mouse = "a"

-- Word wrap is OFF by default. Toggle per window with <leader>uw. `linebreak` only
-- matters once wrap is switched on: it breaks at word boundaries, not mid-word.
opt.wrap = false
opt.linebreak = true

-- UI
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false
opt.laststatus = 3
opt.splitright = true
opt.splitbelow = true
opt.winborder = "rounded"

-- System clipboard (wl-clipboard is installed, so this works under Wayland).
opt.clipboard = "unnamedplus"

-- oil.nvim replaces netrw; keep netrw out of the way.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
