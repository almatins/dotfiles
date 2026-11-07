local M = {}

local ERR = { "[Ee]rror", "Exception", "FAILED", "^E/flutter", "══╡ EXCEPTION", "Unhandled", "panic", "fatal" }

function M.copy(text, msg)
  vim.fn.setreg("+", text)
  if vim.fn.executable("wl-copy") == 1 then vim.fn.system({ "wl-copy" }, text) end
  vim.notify(msg or ("Copied " .. #vim.split(text, "\n") .. " lines"))
end

local function is_err(line)
  for _, p in ipairs(ERR) do if line:find(p) then return true end end
  return false
end

-- Lines of the buffer that belong to error blocks: from an error line to the next blank line.
function M.error_blocks(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local out, on = {}, false
  for _, l in ipairs(lines) do
    if is_err(l) then on = true end
    if on then
      if l:match("^%s*$") then on = false; table.insert(out, "") else table.insert(out, l) end
    end
  end
  return out
end

function M.yank_all(buf)
  M.copy(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
end

function M.yank_errors(buf)
  local o = M.error_blocks(buf)
  if #o == 0 then return vim.notify("No error lines found", vim.log.levels.WARN) end
  M.copy(table.concat(o, "\n"))
end

-- Open `cmd` in a terminal split; returns buf, job id.
function M.run(cmd, opts)
  opts = opts or {}
  vim.cmd(opts.split or "botright 18split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buf)
  local job = vim.fn.jobstart(cmd, { term = true, cwd = opts.cwd })
  vim.api.nvim_buf_set_name(buf, opts.name or ("term://" .. (type(cmd) == "table" and cmd[1] or cmd)))
  vim.bo[buf].scrollback = 100000
  return buf, job
end

return M
