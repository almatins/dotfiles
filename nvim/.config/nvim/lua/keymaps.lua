-- Keymaps: the tmux-mirrored layer from KEYMAP.md.
--
-- Space is the leader. tmux owns C-a and nothing else, so the same letter means the
-- same verb one scope inward:
--
--     concept      tmux      neovim
--     split right  C-a |     <leader>|
--     split below  C-a -     <leader>-
--     close        C-a x     <leader>x
--     zoom         C-a z     <leader>z
--     find         C-a f     <leader>ff

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- Increment / decrement, rehomed off <C-a>
-- ---------------------------------------------------------------------------
-- tmux consumes <C-a> before Neovim ever sees the byte, so Vim's increment command is
-- unreachable. It moves to +, and <C-x> follows to - for symmetry. The keys they
-- displace (first non-blank of the next/previous line) are no loss.
map({ "n", "v" }, "+", "<C-a>", { desc = "Increment number" })
map({ "n", "v" }, "-", "<C-x>", { desc = "Decrement number" })
map("v", "g+", "g<C-a>", { desc = "Increment as sequence" })
map("v", "g-", "g<C-x>", { desc = "Decrement as sequence" })

-- ---------------------------------------------------------------------------
-- Windows and buffers
-- ---------------------------------------------------------------------------
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>z", function()
  require("mini.misc").zoom()
end, { desc = "Zoom window" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window" })

-- Buffer close keeps the window and its layout: plain :bdelete tears the split down.
map("n", "<leader>x", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Close buffer" })
map("n", "<leader>bd", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Close buffer" })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Alternate buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- Moving lines and selections is mini.move's default: <A-j>/<A-k> in n/v/x mode.
-- Remapping them here would only add a second definition of the same thing.

-- ---------------------------------------------------------------------------
-- Saving and search highlight
-- ---------------------------------------------------------------------------
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- ---------------------------------------------------------------------------
-- Finding (mini.pick + mini.extra)
-- ---------------------------------------------------------------------------
map("n", "<leader><space>", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })
map("n", "<leader>ff", function()
  require("mini.pick").builtin.files()
end, { desc = "Find files" })
map("n", "<leader>fr", function()
  require("mini.extra").pickers.oldfiles()
end, { desc = "Recent files" })
map("n", "<leader>fg", function()
  require("mini.extra").pickers.git_files()
end, { desc = "Find git files" })
map("n", "<leader>,", function()
  require("mini.pick").builtin.buffers()
end, { desc = "Buffers" })
map("n", "<leader>/", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Grep (root)" })
map("n", "<leader>sg", function()
  require("mini.pick").builtin.grep_live()
end, { desc = "Grep (root)" })
map("n", "<leader>sw", function()
  require("mini.pick").builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "Grep word under cursor" })
map("n", "<leader>sd", function()
  require("mini.extra").pickers.diagnostic()
end, { desc = "Diagnostics (picker)" })
map("n", "<leader>sk", function()
  require("mini.extra").pickers.keymaps()
end, { desc = "Search keymaps" })
map("n", "<leader>sh", function()
  require("mini.pick").builtin.help()
end, { desc = "Search help" })
map("n", "<leader>ss", function()
  require("mini.extra").pickers.lsp({ scope = "document_symbol" })
end, { desc = "Symbols in buffer" })
map("n", "<leader>sS", function()
  require("mini.extra").pickers.lsp({ scope = "workspace_symbol" })
end, { desc = "Symbols in workspace" })

-- File explorer
map("n", "<leader>e", function()
  require("mini.files").open()
end, { desc = "File explorer" })
map("n", "<leader>E", function()
  require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
end, { desc = "Reveal current file" })

-- ---------------------------------------------------------------------------
-- Code
-- ---------------------------------------------------------------------------
-- gd / gr / gI / gy / K / gra are Neovim 0.11+ built-ins and are deliberately NOT
-- remapped: every override is a thing that breaks on upgrade.
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.organizeImports" }, diagnostics = {} },
    apply = true,
  })
end, { desc = "Organize imports" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cl", "<cmd>checkhealth lsp<cr>", { desc = "LSP info" })
-- 0.11 ships signature help on <C-s> in insert mode, but <C-s> is save here (and the
-- tmux/bash layer already expects it). Move it to gK / <C-k>.
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- ---------------------------------------------------------------------------
-- Flutter (flutter-tools)
-- ---------------------------------------------------------------------------
-- Capital F: lowercase <leader>f is the find group. dartls is started by
-- flutter-tools, not by lsp.lua, so these commands are the only way to drive it.
local flutter = {
  { "<leader>Fr", "FlutterRun", "Run" },
  { "<leader>FR", "FlutterRestart", "Hot restart" },
  { "<leader>Fl", "FlutterReload", "Hot reload" },
  { "<leader>Fq", "FlutterQuit", "Quit" },
  { "<leader>Fd", "FlutterDevices", "Devices" },
  { "<leader>Fe", "FlutterEmulators", "Emulators" },
  { "<leader>Fo", "FlutterOutlineToggle", "Widget outline" },
  { "<leader>FD", "FlutterDevTools", "DevTools" },
  { "<leader>FL", "FlutterLogToggle", "Dev log" },
  { "<leader>Fs", "FlutterLspRestart", "Restart dartls" },
}
-- flutter-tools only registers its commands on the first *.dart or pubspec.yaml buffer
-- (BufEnter, once). Pressing <leader>Fr in a JS file would otherwise be E492.
local function flutter_cmd(name)
  return function()
    if vim.fn.exists(":" .. name) == 2 then
      vim.cmd(name)
    else
      vim.notify("flutter-tools: open a .dart or pubspec.yaml buffer first", vim.log.levels.WARN)
    end
  end
end

for _, m in ipairs(flutter) do
  map("n", m[1], flutter_cmd(m[2]), { desc = m[3] })
end

-- ---------------------------------------------------------------------------
-- Git (gitsigns)
-- ---------------------------------------------------------------------------
map("n", "<leader>gs", function()
  require("gitsigns").stage_hunk()
end, { desc = "Stage hunk" })
map("n", "<leader>gr", function()
  require("gitsigns").reset_hunk()
end, { desc = "Reset hunk" })
map("n", "<leader>gp", function()
  require("gitsigns").preview_hunk()
end, { desc = "Preview hunk" })
map("n", "<leader>gb", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Blame line" })
map("n", "<leader>gd", function()
  require("gitsigns").diffthis()
end, { desc = "Diff this" })
map("n", "]h", function()
  require("gitsigns").next_hunk()
end, { desc = "Next hunk" })
map("n", "[h", function()
  require("gitsigns").prev_hunk()
end, { desc = "Previous hunk" })

-- ---------------------------------------------------------------------------
-- Diagnostics lists and quitting
-- ---------------------------------------------------------------------------
map("n", "<leader>Xx", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostics list" })
map("n", "<leader>Xq", "<cmd>copen<cr>", { desc = "Quickfix list" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
