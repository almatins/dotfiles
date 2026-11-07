local T = require("util.term")
local state = { buf = nil, job = nil, device = nil }

local function project_root()
  local f = vim.fs.find("pubspec.yaml", { upward = true, path = vim.fn.expand("%:p:h") })[1]
  return f and vim.fs.dirname(f) or nil
end

local function with_root(cb)
  local r = project_root()
  if r then return cb(r) end
  local list = vim.fs.find("pubspec.yaml", { path = vim.fn.getcwd(), limit = 30, type = "file" })
  if #list == 0 then return vim.notify("No pubspec.yaml found", vim.log.levels.WARN) end
  if #list == 1 then return cb(vim.fs.dirname(list[1])) end
  local items = vim.tbl_map(function(p) return { text = vim.fs.dirname(p), dir = vim.fs.dirname(p) } end, list)
  Snacks.picker({ title = "Flutter project", items = items, format = "text",
    confirm = function(p, it) p:close(); if it then cb(it.dir) end end })
end

local function alive() return state.job and vim.fn.jobwait({ state.job }, 0)[1] == -1 end
local function send(k)
  if alive() then vim.fn.chansend(state.job, k) else vim.notify("No flutter run in progress", vim.log.levels.WARN) end
end

local function run(extra)
  with_root(function(root)
    local cmd = { "flutter", "run", "-v" }
    if state.device then vim.list_extend(cmd, { "-d", state.device }) end
    if extra and extra ~= "" then vim.list_extend(cmd, vim.split(extra, "%s+")) end
    state.buf, state.job = T.run(cmd, { cwd = root, name = "flutter-run://" .. root })
  end)
end

local function devices()
  local out = vim.fn.systemlist({ "flutter", "devices", "--machine" })
  local ok, data = pcall(vim.json.decode, table.concat(out, "\n"))
  if not ok then return vim.notify("flutter devices failed", vim.log.levels.ERROR) end
  local items = vim.tbl_map(function(d) return { text = d.name .. " (" .. d.id .. ")", id = d.id } end, data)
  Snacks.picker({ title = "Flutter device", items = items, format = "text",
    confirm = function(p, it) p:close(); if it then state.device = it.id; vim.notify("Device: " .. it.id) end end })
end

local function cur() return state.buf and vim.api.nvim_buf_is_valid(state.buf) and state.buf or vim.api.nvim_get_current_buf() end

local function to_quickfix()
  local lines = vim.api.nvim_buf_get_lines(cur(), 0, -1, false)
  vim.fn.setqflist({}, " ", { title = "Flutter errors", lines = lines,
    efm = "%f:%l:%c: Error: %m,%f:%l:%c: %trror - %m,%f:%l:%c: %tarning: %m,%E%f:%l:%c: %m" })
  vim.cmd("copen")
end

return {
  { "akinsho/flutter-tools.nvim", ft = "dart", dependencies = { "nvim-lua/plenary.nvim" },
    opts = { lsp = { settings = { showTodos = true } }, widget_guides = { enabled = true },
      closing_tags = { enabled = true, prefix = "// " }, outline = { open_cmd = "botright 40vnew" } },
    keys = { { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Widget outline", ft = "dart" } } },
  { name = "view-flutter", dir = vim.fn.stdpath("config"), lazy = false,
    keys = {
      { "<leader>Fr", function() run() end, desc = "Run (-v)" },
      { "<leader>FR", function() vim.ui.input({ prompt = "flutter run -v extra args: " }, function(a) if a then run(a) end end) end, desc = "Run with args" },
      { "<leader>Fd", devices, desc = "Pick device" },
      { "<leader>Fl", function() send("r") end, desc = "Hot reload" },
      { "<leader>FH", function() send("R") end, desc = "Hot restart" },
      { "<leader>Fq", function() send("q") end, desc = "Quit run" },
      { "<leader>Ft", function() if state.buf and vim.api.nvim_buf_is_valid(state.buf) then vim.cmd("botright 18split | buffer " .. state.buf) end end, desc = "Show run terminal" },
      { "<leader>Fy", function() T.yank_all(cur()) end, desc = "Copy full log" },
      { "<leader>FY", function() T.yank_errors(cur()) end, desc = "Copy errors only" },
      { "<leader>Fe", to_quickfix, desc = "Errors -> quickfix" },
    } },
}
