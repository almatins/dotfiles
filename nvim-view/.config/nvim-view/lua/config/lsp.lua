-- Navigation-only LSP: no rename / code action / format keys.
vim.diagnostic.config({ virtual_text = false, underline = true, signs = true, severity_sort = true })
vim.lsp.config("vtsls", {})
for _, s in ipairs({ "gopls", "vtsls", "basedpyright", "marksman" }) do
  if vim.fn.executable(s == "basedpyright" and "basedpyright-langserver" or s) == 1 then
    vim.lsp.enable(s)
  end
end
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local m = function(k, f, d) vim.keymap.set("n", k, f, { buffer = ev.buf, desc = d }) end
    m("gd", function() Snacks.picker.lsp_definitions() end, "Definition")
    m("gr", function() Snacks.picker.lsp_references() end, "References")
    m("gI", function() Snacks.picker.lsp_implementations() end, "Implementation")
    m("gy", function() Snacks.picker.lsp_type_definitions() end, "Type definition")
    m("K", vim.lsp.buf.hover, "Hover")
    m("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
    m("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
    m("<leader>cd", vim.diagnostic.open_float, "Line diagnostic")
  end,
})
