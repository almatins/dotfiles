-- Formatting: conform.nvim.
--
-- Every formatter below is an external binary and is NOT installed by Neovim any more
-- (Mason is gone). conform skips a formatter whose binary is absent, so this file is
-- safe to leave as-is; install a binary and it starts working on the next save.
--
--   npm i -g prettier
--   dnf install golang && go install mvdan.cc/gofumpt@latest
--   go install golang.org/x/tools/cmd/goimports@latest
--   uv tool install ruff
--   dnf install shfmt
--   stylua      (GitHub release -> ~/.local/bin)
--   dart        (already on PATH via the Flutter SDK)

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    html = { "prettier" },
    dart = { "dart_format" },
    go = { "gofumpt", "goimports" },
    python = { "ruff_format", "ruff_organize_imports" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})

vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })
