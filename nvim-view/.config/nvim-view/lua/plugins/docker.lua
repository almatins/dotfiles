local T = require("util.term")

local function containers()
  local out = vim.fn.systemlist({ "docker", "ps", "-a", "--format", "{{.Names}}\t{{.Image}}\t{{.Status}}" })
  if vim.v.shell_error ~= 0 then
    vim.notify("docker ps failed:\n" .. table.concat(out, "\n"), vim.log.levels.ERROR)
    return {}
  end
  local items = {}
  for _, l in ipairs(out) do
    local n, i, s = l:match("^(.-)\t(.-)\t(.*)$")
    if n then items[#items + 1] = { text = n .. " " .. i .. " " .. s, name = n, image = i, status = s } end
  end
  return items
end

local function pick(on_choice)
  local items = containers()
  if #items == 0 then return end
  Snacks.picker({
    title = "Containers", items = items,
    format = function(it) return { { it.name, "Title" }, { "  " .. it.image, "Comment" }, { "  " .. it.status, "Special" } } end,
    confirm = function(p, it) p:close(); if it then on_choice(it) end end,
  })
end

local function logs(c, filter)
  local cmd = "docker logs -f --tail 500 --timestamps " .. vim.fn.shellescape(c.name) .. " 2>&1"
  if filter then cmd = cmd .. " | rg --line-buffered -i 'error|warn|fatal|panic|exception'" end
  T.run({ "bash", "-c", cmd }, { name = "docker-logs://" .. c.name .. (filter and "?errors" or "") })
end

local function inspect(c)
  local out = vim.fn.systemlist({ "docker", "inspect", c.name })
  vim.cmd("botright vnew")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
  vim.bo.buftype, vim.bo.bufhidden, vim.bo.filetype, vim.bo.modifiable = "nofile", "wipe", "json", false
end

return {
  { name = "view-docker", dir = vim.fn.stdpath("config"), lazy = false,
    keys = {
      { "<leader>Dc", function() pick(logs) end, desc = "Container logs (pick)" },
      { "<leader>Dl", function() pick(logs) end, desc = "Container logs (follow)" },
      { "<leader>De", function() pick(function(c) logs(c, true) end) end, desc = "Container errors only" },
      { "<leader>Di", function() pick(inspect) end, desc = "Inspect container" },
      { "<leader>Dk", function()
          T.run({ "docker", "compose", "logs", "-f", "--tail", "200" }, { name = "docker-compose-logs", cwd = vim.fn.getcwd() })
        end, desc = "Compose logs (cwd)" },
      { "<leader>Dy", function() T.yank_all(vim.api.nvim_get_current_buf()) end, desc = "Copy log buffer" },
    } },
}
