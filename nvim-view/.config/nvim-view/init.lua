-- Read-only Neovim viewer. Launch with `nv` (NVIM_APPNAME=nvim-view nvim).
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Reuse LSP binaries already installed by the main config's Mason.
vim.env.PATH = vim.fn.expand("~/.local/share/nvim/mason/bin") .. ":" .. vim.env.PATH

require("config.options")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then error("Failed to clone lazy.nvim:\n" .. out) end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})

require("config.readonly")
require("config.keymaps")
require("config.lsp")
