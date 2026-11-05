-- Plugins, managed by Neovim 0.12's built-in vim.pack. No bootstrap snippet: vim.pack
-- clones anything missing on the first start.
--
--   :lua vim.pack.update()                   update every plugin (shows a diff first)
--   :lua vim.pack.get()                      list what is installed
--   :lua vim.pack.update({ 'blink.cmp' })    update one
--
-- Plugins land in ~/.local/share/nvim/site/pack/core/opt/ and are NOT in this repo.
-- The committed lockfile (nvim-pack-lock.json) pins the exact revision of each.

-- nvim-treesitter's parsers must be rebuilt whenever the plugin is installed/updated.
-- Registered BEFORE vim.pack.add() so it also fires on the very first clone.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-changed", { clear = true }),
  callback = function(ev)
    local d = ev.data
    if d.spec.name == "nvim-treesitter" and (d.kind == "install" or d.kind == "update") then
      if not d.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      pcall(vim.cmd, "TSUpdate")
    end
  end,
})

vim.pack.add({
  -- The repo is called "nvim"; the explicit name is what `require("catppuccin")` expects.
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/stevearc/oil.nvim" },
  -- 1.x tags ship a prebuilt Rust fuzzy matcher, so no Rust toolchain is needed.
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  -- Only supplies the per-server default configs; Neovim itself runs the client.
  { src = "https://github.com/neovim/nvim-lspconfig" },
  -- `main` is the rewrite for 0.11+; `master` is the unmaintained old branch.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/folke/sidekick.nvim" },
}, { confirm = false })

-- Colourscheme ---------------------------------------------------------------
-- auto_integrations (the default) themes fzf-lua, blink.cmp, render-markdown, etc.
-- because they are installed; tree-sitter and LSP semantic-token groups are built in.
-- Flavours: latte (light), frappe, macchiato, mocha (darkest).
require("catppuccin").setup({
  flavour = "mocha",
  lsp_styles = {
    -- Italic diagnostics text is hard to read at small sizes; keep the underlines.
    virtual_text = {
      errors = { "bold" },
      hints = {},
      warnings = {},
      information = {},
      ok = {},
    },
  },
})
vim.cmd.colorscheme("catppuccin")

-- Icons ----------------------------------------------------------------------
-- Tiny and dependency-free; lets oil, fzf-lua and render-markdown find icons without
-- nvim-web-devicons.
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- Fuzzy finder ---------------------------------------------------------------
-- Shells out to fzf, fd and ripgrep. Also takes over vim.ui.select, so code actions
-- and other prompts use the same picker.
local fzf = require("fzf-lua")
fzf.setup({
  files = { formatter = "path.filename_first" },
})
fzf.register_ui_select()

-- File explorer --------------------------------------------------------------
-- The directory is a buffer: rename, move and delete by editing text, then :w.
-- Oil's default in-buffer keymaps are kept as-is (g? lists them).
require("oil").setup({
  default_file_explorer = true,
  view_options = { show_hidden = true },
})

-- Completion -----------------------------------------------------------------
-- Default preset: <C-space> open, <C-n>/<C-p> move, <C-y> accept, <C-e> dismiss,
-- <C-k> signature help. Switch to preset = "enter" for accept-on-Enter.
require("blink.cmp").setup({
  keymap = { preset = "default" },
  completion = { documentation = { auto_show = true, auto_show_delay_ms = 250 } },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
})

-- Markdown -------------------------------------------------------------------
-- Rendered in the buffer itself (headings, tables, code blocks, checkboxes). Needs the
-- `markdown` and `markdown_inline` tree-sitter parsers, installed in treesitter.lua.
require("render-markdown").setup({
  file_types = { "markdown" },
})

-- AI agents ------------------------------------------------------------------
-- sidekick runs each CLI agent in a terminal split and can pipe the current file,
-- selection or diagnostics into it. claude, codex and opencode are built in; pi and
-- kiro-cli are added below. Keymaps live in keymaps.lua.
require("sidekick").setup({
  nes = { enabled = false }, -- next-edit-suggestions needs Copilot; not used here
  cli = {
    picker = "fzf-lua", -- the default is snacks.nvim, which is not installed
    tools = {
      pi = { cmd = { "pi" } },
      kiro = { cmd = { "kiro-cli" } },
    },
  },
})
