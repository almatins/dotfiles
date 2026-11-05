-- Treesitter.
--
-- On the `main` branch there is no `ensure_installed` and no highlight module: you
-- install the parsers you want and start highlighting per buffer. Parsers compile
-- from C on install (cc and make are present).

local want = {
  -- editing this config
  "lua", "vim", "vimdoc", "query",
  -- Node / Vue frontends and the Express services
  "javascript", "typescript", "tsx", "vue", "json", "html", "css", "scss",
  -- Flutter
  "dart",
  -- MariSafe backend
  "go", "gomod", "gosum",
  -- Kotlin
  "kotlin",
  -- Python
  "python",
  -- prose, config and infra files this repo is full of
  "bash", "yaml", "toml", "dockerfile", "sql", "markdown", "markdown_inline",
  "gitcommit", "diff", "gitignore", "xml",
}

local ok, ts = pcall(require, "nvim-treesitter")
if ok then
  -- Install only what is missing. Re-checking the whole list against the registry on
  -- every start is needlessly slow once the parsers exist.
  local have = {}
  for _, p in ipairs(ts.get_installed()) do
    have[p] = true
  end

  local missing = vim.tbl_filter(function(p)
    return not have[p]
  end, want)

  if #missing > 0 then
    ts.install(missing)
  end

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
    callback = function(ev)
      -- A filetype without an installed parser is normal, not an error.
      pcall(vim.treesitter.start, ev.buf)
      -- Indentation via the parser, when the module exposes it.
      pcall(function()
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end)
    end,
  })
end
