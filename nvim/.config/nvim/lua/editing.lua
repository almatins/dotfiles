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

-- Spreadsheets are not text ---------------------------------------------------
-- An .xlsx/.ods is a ZIP of XML, so reading it into a buffer only shows garbage.
-- Intercept the read and hand the file to the desktop's default app instead
-- (LibreOffice Calc is the xdg-mime handler for these types here). This is what
-- makes oil, fzf-lua and `:e report.xlsx` safe; csvview stays CSV/TSV-only on purpose.
local spreadsheet_patterns = { "*.xlsx", "*.xlsm", "*.xls", "*.ods" }

-- The runtime zip plugin claims the same extensions, so a spreadsheet would also be
-- browsed as an archive (and error out on a file that is not a zip). It registers its
-- autocommands after init.lua runs, so they cannot be dropped at startup: clear its
-- claim for these patterns from inside our handler, which also covers later opens.
-- Archive browsing for .zip, .jar, .docx and friends is left alone.
local function release_zip_claims()
  for _, pat in ipairs(spreadsheet_patterns) do
    pcall(vim.api.nvim_clear_autocmds, { group = "zip", event = "BufReadCmd", pattern = pat })
  end
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  group = vim.api.nvim_create_augroup("desktop-open", { clear = true }),
  pattern = spreadsheet_patterns,
  callback = function(ev)
    release_zip_claims()

    local buf, name = ev.buf, vim.fn.fnamemodify(ev.file, ":t")
    if vim.uv.fs_stat(ev.file) == nil then
      vim.notify(name .. " does not exist", vim.log.levels.WARN)
    elseif vim.fn.executable("xdg-open") == 0 then
      vim.notify("xdg-open is not installed; cannot open " .. name, vim.log.levels.ERROR)
    else
      vim.notify("Opening " .. name .. " in the desktop app")
      -- detach: the opening app outlives the buffer we are about to drop.
      vim.system({ "xdg-open", ev.file }, { detach = true })
    end
    -- Never leave the binary (or an empty stub) behind: wipe the buffer. With other
    -- buffers open you land back on the previous one; if it was the only buffer the
    -- window shows an empty one instead of quitting nvim.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.cmd("bwipeout! " .. buf)
      end
    end)
  end,
})
