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

-- Indentation per language. Neovim's built-in ftplugins set most of this; these win
-- because they run after them. A project's .editorconfig overrides all of it (Neovim
-- reads it natively), and so do prettier/ruff/ktlint configs at format time.
--   2 spaces: web, data and Dart (prettier / dart format defaults)
--   4 spaces: Python (ruff), Kotlin (ktlint)
--   tabs:     Go (gofmt); tabstop is display width only
local indent = {
  { { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "jsonc", "html", "css", "yaml", "markdown", "lua", "dart", "sh", "bash" }, 2, true },
  { { "python", "kotlin" }, 4, true },
  { { "go", "gomod" }, 4, false },
}
for _, rule in ipairs(indent) do
  local fts, width, spaces = rule[1], rule[2], rule[3]
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("indent-" .. fts[1], { clear = true }),
    pattern = fts,
    callback = function(ev)
      local bo = vim.bo[ev.buf]
      bo.shiftwidth, bo.tabstop, bo.softtabstop, bo.expandtab = width, width, width, spaces
    end,
  })
end

-- System clipboard (wl-clipboard is installed, so this works under Wayland).
opt.clipboard = "unnamedplus"

-- oil.nvim replaces netrw; keep netrw out of the way.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
