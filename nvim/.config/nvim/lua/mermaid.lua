-- Mermaid previews as Unicode art, rendered by mermaid-ascii (Go binary).
--
-- No image protocol and no node: the output is plain text, so it works inside tmux and
-- over SSH. The preview buffer is read-only; `q` closes the split. Supported diagram
-- types are the ones mermaid-ascii knows: flowchart/graph, sequenceDiagram, erDiagram.
--
-- Install the binary with: go install github.com/AlexanderGrooff/mermaid-ascii@latest

local M = {}

-- In a markdown buffer, return the ```mermaid fence surrounding the cursor.
local function fence_block()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local start

  for i = row, 1, -1 do
    if lines[i]:match("^%s*```%s*[Mm]ermaid%s*$") then
      start = i
      break
    elseif lines[i]:match("^%s*```%s*$") then
      break -- hit the closing fence of another block before any mermaid opener
    end
  end
  if not start then
    return nil
  end

  local body = {}
  for i = start + 1, #lines do
    if lines[i]:match("^%s*```%s*$") then
      break
    end
    body[#body + 1] = lines[i]
  end
  return #body > 0 and table.concat(body, "\n") or nil
end

--- Source of the diagram to render: the whole .mmd/.mermaid buffer, or the fenced
--- block under the cursor in markdown.
function M.source()
  if vim.bo.filetype == "mermaid" then
    return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  end
  if vim.bo.filetype == "markdown" then
    return fence_block()
  end
end

-- mermaid-ascii paints classDef nodes with SGR escapes. A scratch buffer shows those
-- literally (^[[38;2;255;0;0m), so strip them: the shape of the art is the point, and
-- keeping the escape bytes would also break yanking the preview.
local function strip_ansi(s)
  return (s:gsub("\27%[[%d;]*m", ""))
end

function M.show()
  local src = M.source()
  if not src then
    vim.notify("No mermaid diagram at the cursor", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("mermaid-ascii") == 0 then
    vim.notify(
      "mermaid-ascii is not installed (go install github.com/AlexanderGrooff/mermaid-ascii@latest)",
      vim.log.levels.ERROR
    )
    return
  end

  -- `--max-width auto` needs a TTY, and stdout is a pipe here, so pass the width in.
  local width = tostring(math.max(20, vim.api.nvim_win_get_width(0) - 2))
  vim.system({ "mermaid-ascii", "--max-width", width, "-f", "-" }, { stdin = src, text = true }, function(out)
    vim.schedule(function()
      if out.code ~= 0 then
        vim.notify("mermaid-ascii: " .. (out.stderr or "failed"), vim.log.levels.ERROR)
        return
      end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(strip_ansi(out.stdout):gsub("\n$", ""), "\n"))
      vim.cmd("botright vnew")
      vim.api.nvim_win_set_buf(0, buf)
      vim.wo.wrap = false
      vim.bo[buf].readonly = true
      vim.bo[buf].modifiable = false
      vim.bo[buf].bufhidden = "wipe"
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close mermaid preview" })
    end)
  end)
end

return M
