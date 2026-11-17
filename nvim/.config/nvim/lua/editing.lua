-- Editing helpers: auto pairs, surround, sessions.

-- Auto pairs -----------------------------------------------------------------
-- Inserting ( [ { " ' ` adds the closing character; <BS> removes both; <CR> between
-- a pair opens an indented block. check_ts skips pairing inside strings/comments.
-- Its own insert-mode keys (<CR>, <BS>, <C-h>, <M-e>) are kept as shipped.
require("nvim-autopairs").setup({ check_ts = true })

-- Surround -------------------------------------------------------------------
-- Default keys, same as vim-surround:
--   ys{motion}{char}   add     ysiw)  surround word with ()    ysa"'  quotes -> ' '
--   ds{char}           delete  ds"    remove surrounding quotes
--   cs{old}{new}       change  cs"'   "text" -> 'text'
--   S{char}            visual: surround the selection
-- Aliases: b = ), B = }, r = ], q = any quote. Opening chars ( [ { add inner spaces.
require("nvim-surround").setup({})

-- Sessions -------------------------------------------------------------------
-- One session per working directory + git branch, saved automatically on exit.
-- Nothing is restored automatically: you choose, so opening `nvim file` never surprises
-- you. persistence ships no keymaps; these are the ones its README suggests.
require("persistence").setup({})

local map = vim.keymap.set
map("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Restore session (this dir)" })
map("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select a session" })
map("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Restore last session" })
map("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't save this session" })

-- CSV/TSV tables --------------------------------------------------------------
-- Neovim already detects both filetypes. csvview only draws virtual text, so the
-- write lock costs nothing; <leader>cw in keymaps.lua unlocks a file for editing.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("csv-view", { clear = true }),
  pattern = { "csv", "tsv" },
  callback = function(ev)
    local bo = vim.bo[ev.buf]
    bo.readonly, bo.modifiable = true, false
    require("csvview").enable(ev.buf)
  end,
})
