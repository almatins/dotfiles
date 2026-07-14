-- Move LazyVim's Trouble group off <leader>x so that key can mean "close", matching
-- tmux's C-a x. See lua/config/keymaps.lua for the rationale.
--
-- lazy.nvim merges a spec's `keys` list by concatenation, so a plain table here would
-- ADD to the stock mappings rather than replace them, leaving <leader>x half-shadowed.
-- Returning a function replaces the list outright — that is the only form that works.
--
-- Diagnostics remain reachable three other ways regardless: <leader>sd (picker),
-- <leader>cd (current line), and ]d / [d.

return {
  {
    "folke/trouble.nvim",
    keys = function()
      return {
        { "<leader>Xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        {
          "<leader>XX",
          "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
          desc = "Buffer Diagnostics (Trouble)",
        },
        { "<leader>XL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
        { "<leader>XQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },

        -- These two were never under <leader>x; kept exactly as LazyVim ships them.
        { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
        { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      }
    end,
  },

  {
    "folke/todo-comments.nvim",
    keys = function()
      return {
        {
          "]t",
          function()
            require("todo-comments").jump_next()
          end,
          desc = "Next Todo Comment",
        },
        {
          "[t",
          function()
            require("todo-comments").jump_prev()
          end,
          desc = "Previous Todo Comment",
        },
        { "<leader>Xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
        {
          "<leader>XT",
          "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
          desc = "Todo/Fix/Fixme (Trouble)",
        },
        { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
        { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
      }
    end,
  },
}
