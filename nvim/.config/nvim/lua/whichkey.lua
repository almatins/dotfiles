-- Key popup: which-key.nvim.
--
-- Press <leader> (Space), or g, z, [, ], <C-w>, " and wait ~200ms: a popup lists what
-- can come next. Every keymap with a `desc` shows up automatically, so this file only
-- names the groups. Defaults (look, delay, triggers, built-in help for marks/registers/
-- window commands) are kept as shipped.
--
-- `<leader>?` is the key its README suggests: it lists only the keymaps of the current
-- buffer, which is where gitsigns' hunk keys live.

local wk = require("which-key")

wk.setup({})

wk.add({
  { "<leader>f", group = "find" },
  { "<leader>s", group = "search" },
  { "<leader>g", group = "git" },
  { "<leader>h", group = "hunks", mode = { "n", "x" } },
  { "<leader>a", group = "ai agents", mode = { "n", "x" } },
  { "<leader>m", group = "markdown" },
  { "<leader>q", group = "session" },
  { "<leader>c", group = "code" },
  { "<leader>t", group = "toggle" },
  { "<leader>u", group = "ui" },
  { "<leader>w", group = "window" },
  {
    "<leader>?",
    function()
      wk.show({ global = false })
    end,
    desc = "Buffer-local keymaps",
  },
})
