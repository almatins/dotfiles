-- Plugins, managed by Neovim 0.12's built-in vim.pack. No bootstrap snippet: vim.pack
-- clones anything missing on the first start.
--
--   :lua vim.pack.update()                        update every plugin
--   :lua vim.pack.get()                           list what is installed
--   :lua vim.pack.update({ 'mini.nvim' })         update one
--
-- Plugins land in ~/.local/share/nvim/site/pack/core/opt/ and are NOT in this repo.
-- The committed lockfile (nvim-pack-lock.json) pins the exact revision of each.

vim.pack.add({
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  -- `main` is the rewrite for 0.11+; `master` is the unmaintained old branch and does
  -- not track 0.12.
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/akinsho/flutter-tools.nvim" },
  -- flutter-tools dependency, but vim.pack has no dependency resolution: list it.
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})

-- Colourscheme ---------------------------------------------------------------
require("tokyonight").setup({ style = "night" })
vim.cmd.colorscheme("tokyonight")

-- mini.nvim ------------------------------------------------------------------
-- One repo, several small modules. Chosen over telescope/fzf-lua/snacks because it
-- needs no third-party plugin and no external binary for its pickers (fzf is absent;
-- fd and rg are on PATH and get used when present).
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

require("mini.statusline").setup()
require("mini.pick").setup()
require("mini.extra").setup()
require("mini.files").setup({ windows = { preview = true } })
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.bufremove").setup()
require("mini.move").setup()
require("mini.misc").setup() -- MiniMisc.zoom() backs <leader>z

-- Leader discoverability: hold <leader> for timeoutlen and a menu of what is bound
-- under it appears.
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
    { mode = "n", keys = "z" },
  },
  clues = {
    clue.gen_clues.g(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.square_brackets(),
    { mode = "n", keys = "<Leader>b", desc = "+buffer" },
    { mode = "n", keys = "<Leader>c", desc = "+code" },
    { mode = "n", keys = "<Leader>f", desc = "+find" },
    { mode = "n", keys = "<Leader>F", desc = "+flutter" },
    { mode = "n", keys = "<Leader>g", desc = "+git" },
    { mode = "n", keys = "<Leader>s", desc = "+search" },
    { mode = "n", keys = "<Leader>w", desc = "+window" },
    { mode = "n", keys = "<Leader>X", desc = "+diagnostics" },
  },
  window = { delay = 300, config = { width = "auto" } },
})

-- Git ------------------------------------------------------------------------
require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
})

-- Flutter --------------------------------------------------------------------
-- dartls alone is not enough for Flutter work: no device picker, no hot reload, no
-- `flutter run`, no DevTools. flutter-tools starts dartls itself, so lsp.lua
-- deliberately does not enable dartls (two clients on one buffer make `gd` a coin
-- flip).
require("flutter-tools").setup({
  lsp = {
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
      renameFilesWithClasses = "prompt",
      updateImportsOnRename = true,
    },
  },
  widget_guides = { enabled = true },
  closing_tags = { enabled = true, highlight = "Comment", prefix = "// " },
  dev_log = { enabled = true, open_cmd = "botright 15split" },
  dev_tools = { autostart = false, auto_open_browser = false },
  outline = { open_cmd = "botright 40vnew", auto_open = false },
})
