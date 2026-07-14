-- LazyVim's `lang.dart` extra is 662 bytes: dartls, a Treesitter parser, dart_format,
-- and a test adapter. It has NO Flutter tooling whatsoever — no device picker, no hot
-- reload, no `flutter run`, no DevTools. With five Flutter Web frontends in this
-- monorepo, that gap is the whole job, so flutter-tools fills it.
--
-- Mapped under <leader>F. Lowercase <leader>f is LazyVim's file group; capital F is
-- unbound in stock LazyVim, so this takes nothing away.

return {
  {
    "akinsho/flutter-tools.nvim",
    lazy = false, -- the commands must exist before a .dart buffer is ever opened
    -- No dressing.nvim: LazyVim already routes vim.ui.select through Snacks, so the
    -- device and emulator pickers get a proper UI for free. Adding dressing on top
    -- means two plugins fighting over vim.ui.select.
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- flutter-tools drives dartls itself. Let it, or two clients race to attach to
      -- the same buffer and go-to-definition becomes a coin flip.
      lsp = {
        -- No `color = {...}` here: flutter-tools deprecates plugin-managed document
        -- colours on Neovim 0.12+, which is what this machine runs. Colour swatches
        -- come from vim.lsp.document_color instead (see the autocmd below).
        settings = {
          showTodos = true,
          completeFunctionCalls = true,
          renameFilesWithClasses = "prompt",
          updateImportsOnRename = true,
        },
      },
      widget_guides = { enabled = true },
      closing_tags = { enabled = true, highlight = "Comment", prefix = "// " },
      dev_log = { enabled = true, open_cmd = "botright 15split" },
      dev_tools = { autostart = false, auto_open_browser = false },
      outline = { open_cmd = "botright 40vnew", auto_open = false },
    },
    keys = {
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Run" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Hot Restart" },
      { "<leader>Fl", "<cmd>FlutterReload<cr>", desc = "Hot Reload" },
      { "<leader>Fq", "<cmd>FlutterQuit<cr>", desc = "Quit" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Devices" },
      { "<leader>Fe", "<cmd>FlutterEmulators<cr>", desc = "Emulators" },
      { "<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Widget Outline" },
      { "<leader>FD", "<cmd>FlutterDevTools<cr>", desc = "DevTools" },
      { "<leader>FL", "<cmd>FlutterLogToggle<cr>", desc = "Dev Log" },
      { "<leader>Fs", "<cmd>FlutterLspRestart<cr>", desc = "Restart dartls" },
    },
  },

  -- lang.dart also registers dartls through nvim-lspconfig, and flutter-tools starts
  -- its own. Left alone, both attach to every .dart buffer: duplicate diagnostics,
  -- duplicate completions, and a go-to-definition that picks a client at random.
  --
  -- A `setup` handler returning true is LazyVim's documented way to say "I am starting
  -- this server myself, skip your default". Deleting opts.servers.dartls instead would
  -- work only as long as this spec is merged last, which is not a promise LazyVim makes.
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        dartls = function()
          return true -- flutter-tools owns dartls
        end,
      },
    },
  },
}
