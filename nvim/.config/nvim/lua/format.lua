-- Formatting: conform.nvim.
--
-- Every formatter below is an external binary. conform skips a formatter whose binary
-- is absent, so this file is safe as-is; install a binary and it starts working on the
-- next save.
--
--   npm i -g prettier
--   go install mvdan.cc/gofumpt@latest
--   go install golang.org/x/tools/cmd/goimports@latest
--   dnf install ruff shfmt
--   stylua      (GitHub release -> ~/.local/bin)
--   ktlint      (GitHub release -> ~/.local/bin; needs a JVM)
--   dart        (already on PATH via the Flutter SDK)

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    dart = { "dart_format" },
    kotlin = { "ktlint" }, -- needs the ktlint binary; skipped silently until installed
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
