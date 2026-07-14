-- LSP.
--
-- Neovim 0.11+ already binds everything that matters, so there is nothing to
-- remap here and <leader> stays small:
--
--     K      hover                grr    references
--     grn    rename               gri    implementation
--     gra    code action          grt    type definition
--     gO     document symbols     C-s    signature help (insert mode)
--     ]d [d  next/prev diagnostic
--
-- C-s is why ~/.bashrc runs `stty -ixon`: with flow control on, C-s freezes the
-- terminal instead of reaching Neovim.

-- Server name (as nvim-lspconfig knows it) -> the binary it needs on PATH.
local servers = {
  lua_ls = 'lua-language-server',
  ts_ls  = 'typescript-language-server',
  gopls  = 'gopls',
  jsonls = 'vscode-json-language-server',
  bashls = 'bash-language-server',
  dartls = 'dart',
}

-- Enable only the servers whose binary actually exists. vim.lsp.enable() on a
-- missing command throws an error notification every single time you open a
-- matching file, which is unbearable. Install a server and it lights up on the
-- next launch; nothing here needs editing.
--
-- As of writing only `dart` is installed. To get the rest:
--   npm i -g typescript typescript-language-server bash-language-server \
--            vscode-langservers-extracted
--   go install golang.org/x/tools/gopls@latest
--   sudo dnf install lua-language-server
local enabled = {}
for name, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then
    table.insert(enabled, name)
  end
end
if #enabled > 0 then
  vim.lsp.enable(enabled)
end

-- Completion is built in as of 0.11 — no nvim-cmp, no blink, no snippet engine.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { prefix = '●' },
  severity_sort = true,
  underline = true,
  float = { border = 'rounded', source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN]  = '●',
      [vim.diagnostic.severity.INFO]  = '●',
      [vim.diagnostic.severity.HINT]  = '●',
    },
  },
})
