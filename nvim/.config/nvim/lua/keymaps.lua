-- Keymaps.
--
-- Rule: plugins keep their own default keymaps. A key is defined here only for a plugin
-- that ships no default entry point (fzf-lua, oil, conform) or for a Neovim built-in
-- that needs a small convenience. Space is the leader (see options.lua).
--
-- Left alone on purpose, because the plugin or Neovim already binds them:
--   blink.cmp  <C-space> <C-n> <C-p> <C-y> <C-e> <C-k>   (insert-mode completion)
--   oil        g? (help) <CR> - <C-s> <C-h> <C-t> <C-p> <C-l> ...  (inside oil buffers)
--   LSP        K gd gr gI gy gra grn gO gD ]d [d          (Neovim 0.11+ built-ins)

local map = vim.keymap.set

-- Normal and visual mode only: insert-mode <C-s> is Neovim's built-in signature help,
-- and <C-l> (built in) already clears search highlight. Vim's `+` and `-` are untouched.
-- Caveat: tmux uses <C-a> as its prefix, so Vim's number increment (<C-a>) does not
-- reach Neovim inside tmux.
map({ "n", "v" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })

-- Windows ---------------------------------------------------------------------
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window" })

-- Word wrap is off by default (options.lua); this flips it for the current window.
map("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("wrap " .. (vim.wo.wrap and "on" or "off"))
  require("lualine").refresh() -- the statusline shows a "wrap" flag while it is on
end, { desc = "Toggle word wrap" })

-- Find (fzf-lua) --------------------------------------------------------------
-- fzf-lua defines no global keymaps of its own.
local function fzf(name, opts)
  return function()
    require("fzf-lua")[name](opts)
  end
end

map("n", "<leader><space>", fzf("files"), { desc = "Find files" })
map("n", "<leader>ff", fzf("files"), { desc = "Find files" })
map("n", "<leader>fr", fzf("oldfiles"), { desc = "Recent files" })
map("n", "<leader>fg", fzf("git_files"), { desc = "Git files" })
map("n", "<leader>,", fzf("buffers"), { desc = "Buffers" })
map("n", "<leader>/", fzf("live_grep"), { desc = "Find in files" })
map("n", "<leader>sg", fzf("live_grep"), { desc = "Find in files" })
map({ "n", "x" }, "<leader>sw", fzf("grep_cword"), { desc = "Grep word under cursor" })
map("n", "<leader>sd", fzf("diagnostics_document"), { desc = "Diagnostics (buffer)" })
map("n", "<leader>sD", fzf("diagnostics_workspace"), { desc = "Diagnostics (workspace)" })
map("n", "<leader>ss", fzf("lsp_document_symbols"), { desc = "Symbols in buffer" })
map("n", "<leader>sS", fzf("lsp_live_workspace_symbols"), { desc = "Symbols in workspace" })
map("n", "<leader>sk", fzf("keymaps"), { desc = "Search keymaps" })
map("n", "<leader>sh", fzf("helptags"), { desc = "Search help" })
map("n", "<leader>sr", fzf("resume"), { desc = "Resume last search" })

-- File explorer (oil) ---------------------------------------------------------
-- oil defines no global keymap. Opens the directory of the current file.
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
map("n", "<leader>E", function()
  require("oil").open(vim.fn.getcwd())
end, { desc = "File explorer (cwd)" })

-- Format (conform) ------------------------------------------------------------
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- Markdown preview in the terminal -------------------------------------------
-- render-markdown already renders in the buffer. This opens glow in a split for a
-- full rendered, scrollable view of the file; q quits the pager. With wrap off, scroll
-- sideways with Left / Right.
map("n", "<leader>mp", function()
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= "markdown" or file == "" then
    vim.notify("not a saved markdown buffer", vim.log.levels.WARN)
    return
  end
  vim.cmd("write")

  -- Follow the wrap setting of the markdown window (off by default, <leader>uw toggles).
  -- glow has no "no wrap" switch -- `-w 0` falls back to 80 -- so wrap-off means a very
  -- wide width plus `less -S`, which chops long lines and scrolls sideways with the
  -- Left / Right arrow keys. Wrap-on keeps glow's own wrapping at the window width.
  local args = { "glow", "-p", file }
  local opts = { term = true }
  if not vim.wo.wrap then
    args = { "glow", "-p", "-w", "1000", file }
    -- Only set when non-empty: an empty Lua table is rejected here (E475) because it
    -- encodes as a list, not a dict.
    opts.env = { PAGER = "less -RS" }
  end

  vim.cmd("botright vnew")
  vim.fn.jobstart(args, opts)
  vim.cmd.startinsert()
end, { desc = "Markdown preview (glow)" })
map("n", "<leader>mt", "<cmd>RenderMarkdown toggle<cr>", { desc = "Toggle markdown rendering" })

-- AI agents (sidekick) --------------------------------------------------------
-- sidekick defines no global keymaps either; these are the ones its README suggests,
-- plus one key per agent. <leader>aa toggles whichever agent you used last.
local function cli(fn, opts)
  return function()
    require("sidekick.cli")[fn](opts)
  end
end

map({ "n", "t", "i", "x" }, "<c-.>", cli("focus"), { desc = "Sidekick: focus" })
map("n", "<leader>aa", cli("toggle"), { desc = "Sidekick: toggle agent" })
map("n", "<leader>as", cli("select"), { desc = "Sidekick: select agent" })
map("n", "<leader>ad", cli("close"), { desc = "Sidekick: detach session" })
map({ "n", "x" }, "<leader>at", cli("send", { msg = "{this}" }), { desc = "Sidekick: send this" })
map("n", "<leader>af", cli("send", { msg = "{file}" }), { desc = "Sidekick: send file" })
map("x", "<leader>av", cli("send", { msg = "{selection}" }), { desc = "Sidekick: send selection" })
map({ "n", "x" }, "<leader>ap", cli("prompt"), { desc = "Sidekick: pick prompt" })

-- pi is on `i`, not `p`: <leader>ap is sidekick's own "pick prompt" key above.
for key, name in pairs({ c = "claude", x = "codex", o = "opencode", i = "pi", k = "kiro" }) do
  map("n", "<leader>a" .. key, cli("toggle", { name = name, focus = true }), {
    desc = "Sidekick: " .. name,
  })
end
