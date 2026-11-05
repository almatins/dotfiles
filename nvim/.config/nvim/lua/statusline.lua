-- Statusline: lualine.nvim.
--
-- One global bar (laststatus = 3, set in options.lua), so there is one statusline for the
-- whole screen instead of one per split.
--
--   [mode] [branch  +added ~changed -removed  diagnostics]  [file]  ...
--   ... [wrap] [LSP servers] [filetype] [progress location]
--
-- Branch and the diff counts come from gitsigns; nothing here shells out to git.

--- Names of the LSP clients attached to the current buffer, e.g. " basedpyright ruff".
local function lsp_clients()
  local names = {}
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    names[#names + 1] = c.name
  end
  return #names > 0 and (" " .. table.concat(names, " ")) or ""
end

--- Shown only when word wrap is on (it is off by default), so you notice it.
local function wrap_flag()
  return vim.wo.wrap and "wrap" or ""
end

require("lualine").setup({
  options = {
    theme = "auto", -- follows catppuccin-<flavour>
    globalstatus = true,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { { "filename", path = 1 } }, -- path = 1: relative to the working dir
    lualine_x = { wrap_flag, lsp_clients, "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
