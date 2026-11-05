-- Git.
--
--   gitsigns   signs in the gutter, hunk staging/reset/preview, blame, diff   (<leader>h*)
--   fzf-lua    status / commits / branches pickers                            (<leader>g*)
--   lazygit    full git UI in a floating terminal                             (<leader>gg)
--
-- gitsigns ships no global keymaps. The ones below are the exact set its README
-- suggests, bound per buffer so they exist only inside git-tracked files.

require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- Navigation. Inside a diff window, fall back to Vim's own ]c / [c.
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gs.nav_hunk("next")
      end
    end, "Next hunk")
    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gs.nav_hunk("prev")
      end
    end, "Previous hunk")

    -- Actions
    map("n", "<leader>hs", gs.stage_hunk, "Stage / unstage hunk")
    map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    map("v", "<leader>hs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Stage selected lines")
    map("v", "<leader>hr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, "Reset selected lines")
    map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
    map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
    map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk inline")
    map("n", "<leader>hb", function()
      gs.blame_line({ full = true })
    end, "Blame line")
    map("n", "<leader>hd", gs.diffthis, "Diff against index")
    map("n", "<leader>hD", function()
      gs.diffthis("~")
    end, "Diff against last commit")
    map("n", "<leader>hq", gs.setqflist, "Hunks -> quickfix (buffer)")
    map("n", "<leader>hQ", function()
      gs.setqflist("all")
    end, "Hunks -> quickfix (all files)")

    -- Toggles
    map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
    map("n", "<leader>tw", gs.toggle_word_diff, "Toggle word diff")

    -- Text object: `vih` selects the hunk under the cursor.
    map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk")
  end,
})

-- Pickers (fzf-lua has no global keymaps of its own) ---------------------------
local map = vim.keymap.set
local function fzf(name)
  return function()
    require("fzf-lua")[name]()
  end
end

map("n", "<leader>gs", fzf("git_status"), { desc = "Git status" })
map("n", "<leader>gc", fzf("git_commits"), { desc = "Git commits (project)" })
map("n", "<leader>gl", fzf("git_bcommits"), { desc = "Git log (this file)" })
map("n", "<leader>gb", fzf("git_branches"), { desc = "Git branches" })
map("n", "<leader>gS", fzf("git_stash"), { desc = "Git stash" })

-- lazygit in a floating terminal ------------------------------------------------
-- Closes itself when lazygit exits; gitsigns picks up the changes on its own.
local function lazygit()
  if vim.fn.executable("lazygit") == 0 then
    vim.notify("lazygit is not installed", vim.log.levels.WARN)
    return
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local ui = vim.api.nvim_list_uis()[1] or { width = 120, height = 40 }
  local width, height = math.floor(ui.width * 0.92), math.floor(ui.height * 0.9)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((ui.width - width) / 2),
    row = math.floor((ui.height - height) / 2),
    style = "minimal",
    border = "rounded",
  })
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    cwd = vim.fn.getcwd(),
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      vim.cmd("checktime") -- reload files lazygit changed on disk
    end,
  })
  vim.cmd.startinsert()
end

map("n", "<leader>gg", lazygit, { desc = "Lazygit" })
