-- Plugins, managed by Neovim 0.12's built-in vim.pack. No lazy.nvim, no bootstrap
-- snippet: vim.pack clones anything missing on startup.
--
--   :lua vim.pack.update()   update everything
--   :lua= vim.pack.get()     list what is installed
--
-- Plugins land in ~/.local/share/nvim/site/pack/core/opt/ and are NOT part of the
-- dotfiles repo.

vim.pack.add({
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  -- The `main` branch is the rewrite targeting Neovim 0.11+; `master` is the old
  -- one and is not maintained against 0.12.
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
})

-- Colourscheme --------------------------------------------------------------

require('tokyonight').setup({ style = 'night' })
vim.cmd.colorscheme('tokyonight')

-- mini.nvim -----------------------------------------------------------------
-- One repo, several small modules. Chosen over telescope/fzf-lua because none of
-- it needs an external binary — fzf and fd are not installed on this machine.

require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.pick').setup()      -- <leader>f, <leader>/, <leader>,
require('mini.extra').setup()     -- extra pickers: diagnostics, keymaps, git
require('mini.files').setup()     -- <leader>e
require('mini.surround').setup()  -- sa/sd/sr: add, delete, replace surrounding
require('mini.pairs').setup()     -- auto-close brackets and quotes

-- Leader discoverability: hold <leader> for timeoutlen and a menu of what is bound
-- under it appears. Worth having while these mappings are still new.
local clue = require('mini.clue')
clue.setup({
  triggers = {
    { mode = 'n', keys = '<Leader>' },
    { mode = 'x', keys = '<Leader>' },
    { mode = 'n', keys = 'g' },
    { mode = 'x', keys = 'g' },
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },
    { mode = 'n', keys = '<C-w>' },
    { mode = 'n', keys = 'z' },
  },
  clues = {
    clue.gen_clues.g(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    { mode = 'n', keys = '<Leader>g', desc = '+git' },
  },
  window = { delay = 300, config = { width = 'auto' } },
})

-- Git -----------------------------------------------------------------------

require('gitsigns').setup({
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
})

-- Treesitter ----------------------------------------------------------------
-- Parsers compile from C on install (cc and make are present). The `main` branch
-- has no `ensure_installed` option and no highlight module: you install parsers
-- yourself and start the highlighter per buffer.

local want = {
  'lua', 'vim', 'vimdoc', 'query',                        -- editing this config
  -- No 'jsonc': the main branch has no such parser and warns on startup. The
  -- json parser already covers jsonc buffers.
  'javascript', 'typescript', 'tsx', 'json',              -- the backend services
  'dart',                                                 -- the Flutter frontends
  'go', 'gomod',
  'bash', 'yaml', 'html', 'css', 'sql', 'dockerfile',
  'markdown', 'markdown_inline', 'gitcommit', 'diff',
}

local ok, ts = pcall(require, 'nvim-treesitter')
if ok then
  -- Install only what is missing. Calling install() with the full list on every
  -- startup re-checks each parser against the registry and is needlessly slow.
  local have = {}
  for _, p in ipairs(ts.get_installed and ts.get_installed() or {}) do
    have[p] = true
  end

  local missing = vim.tbl_filter(function(p) return not have[p] end, want)
  if #missing > 0 then
    ts.install(missing)
  end

  -- Highlighting, folds and indent are opt-in per buffer on the main branch.
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
    callback = function(ev)
      -- pcall: a filetype with no installed parser is normal, not an error.
      pcall(vim.treesitter.start, ev.buf)
    end,
  })
end
