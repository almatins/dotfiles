-- Neovim config built on 0.12 built-ins.
--
--   vim.pack        plugin manager (no lazy.nvim)
--   vim.lsp.*       LSP client, diagnostics, document colour
--   vim.treesitter  highlighting
--
-- Rule: keep every plugin's own default keymaps. A custom key is added only where a
-- plugin has no default entry point (fzf-lua, oil, conform have none) -- see keymaps.lua.
--
-- Load order matters: options set the leader before any keymap exists, and `plugins`
-- must register the packs before anything requires them.

require("options")
require("plugins")
require("lsp")
require("treesitter")
require("format")
require("git")
require("keymaps")
