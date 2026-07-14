-- Autocmds are loaded on the VeryLazy event, after LazyVim's own.

-- Colour swatches next to Color(0xFF...) / Colors.blue in Dart, and next to hex
-- literals in CSS. flutter-tools used to do this itself, but deprecates it on Neovim
-- 0.12+ in favour of the built-in — which is what this is.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_document_color", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, ev.buf)
    end
  end,
})
