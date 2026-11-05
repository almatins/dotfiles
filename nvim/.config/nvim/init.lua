-- Minimal Neovim config, built on 0.12 built-ins.
--
--   vim.pack        plugin manager (no lazy.nvim, no LazyVim)
--   vim.lsp.*       LSP, completion, diagnostics, document colour
--   vim.treesitter  syntax highlighting
--
-- Load order matters: options set the leader and UI before any plugin is configured,
-- and `plugins` has to register the packs before anything requires them.

require("options")
require("plugins")
require("lsp")
require("treesitter")
require("format")
require("keymaps")
