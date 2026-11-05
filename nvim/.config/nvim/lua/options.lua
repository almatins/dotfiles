-- Options only. Nothing here may `require` a plugin: this file runs before any pack
-- is on the runtimepath.

local opt = vim.opt

-- Leader ---------------------------------------------------------------------
-- Space, matching the tmux layer model in KEYMAP.md: tmux owns C-a and nothing else,
-- so Space is invisible to it. Leader must be set before any keymap is registered.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Editing --------------------------------------------------------------------
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
opt.wrap = false
opt.linebreak = true
opt.mouse = "a"

-- UI -------------------------------------------------------------------------
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

-- Completion is Neovim's own (vim.lsp.completion); `fuzzy` is a 0.11+ completeopt
-- flag. Guarded so an older build degrades instead of failing at startup.
pcall(function()
  opt.completeopt = "menu,menuone,noselect,fuzzy"
end)

-- Clipboard: wl-copy is installed, so unnamedplus works under Wayland.
opt.clipboard = "unnamedplus"

-- Netrw is replaced by mini.files; keep it out of the way.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
