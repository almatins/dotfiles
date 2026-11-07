-- Read-only by default; the agent edits files, we read them.
local aug = vim.api.nvim_create_augroup("nvim_view_readonly", { clear = true })

local function lock(buf)
  if vim.bo[buf].buftype == "" then
    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufEnter" }, {
  group = aug,
  callback = function(ev)
    if not vim.b[ev.buf].view_editable then lock(ev.buf) end
  end,
})

-- Escape hatch for a rare manual fix.
vim.keymap.set("n", "<leader>uE", function()
  local b = vim.api.nvim_get_current_buf()
  local editable = not vim.b[b].view_editable
  vim.b[b].view_editable = editable
  vim.bo[b].modifiable = editable
  vim.bo[b].readonly = not editable
  vim.notify(editable and "Editing ENABLED for this buffer" or "Read-only", vim.log.levels.WARN)
end, { desc = "Toggle editable" })

-- Auto-reload: agents rewrite files under us.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose" }, {
  group = aug,
  callback = function()
    if vim.fn.mode() ~= "c" then vim.cmd("silent! checktime") end
  end,
})
local timer = (vim.uv or vim.loop).new_timer()
timer:start(1000, 1000, vim.schedule_wrap(function()
  if vim.fn.mode() ~= "c" then vim.cmd("silent! checktime") end
end))
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = aug,
  callback = function(ev)
    vim.notify("Reloaded " .. vim.fn.fnamemodify(ev.file, ":t"), vim.log.levels.INFO)
  end,
})
