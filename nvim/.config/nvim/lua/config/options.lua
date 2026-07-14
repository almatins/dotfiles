-- Options are loaded before lazy.nvim starts.
-- LazyVim's defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- The leader is Space, which is LazyVim's default — nothing to set here. It is
-- collision-free by construction: tmux's root key-table is empty, so C-a is the only
-- key tmux ever intercepts, and Space is invisible to it.

-- LazyVim's python extra defaults to plain `pyright`:
--     local lsp = vim.g.lazyvim_python_lsp or "pyright"
-- Without this line, pyright is never installed here, so ONLY ruff (a linter) attaches
-- to a Python buffer and you silently get no type checking at all — which is exactly
-- what happened before this was set.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
