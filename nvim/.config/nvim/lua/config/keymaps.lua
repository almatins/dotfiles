-- Keymaps are loaded on the VeryLazy event, after LazyVim's own defaults.
--
-- Deviations from stock LazyVim. Four of them, and no more: every override is a thing
-- that can break on a LazyVim upgrade, so the list is kept deliberately short.
--
-- Companion to ~/.tmux.conf. tmux owns the world OUTSIDE the editor behind the C-a
-- prefix; Neovim owns the world inside it behind the Space leader. The same mnemonic
-- means the same concept at each scope:
--
--     concept      tmux      neovim
--     split right  C-a |     <leader>|     (already a LazyVim default)
--     split below  C-a -     <leader>-     (already a LazyVim default)
--     zoom         C-a z     <leader>z     (aliased below)
--     close        C-a x     <leader>x     (override — LazyVim uses x for Trouble)
--     find         C-a f     <leader>ff    (LazyVim default; <leader>f is its file group)

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- 1. Increment / decrement, rehomed off <C-a>
-- ---------------------------------------------------------------------------
-- tmux takes <C-a> as its prefix and consumes it before Neovim ever sees the byte, so
-- Vim's increment command is unreachable no matter what we bind here. It moves to +,
-- and <C-x> follows to - for symmetry. The keys they displace (first non-blank of the
-- next/previous line) are no loss.
--
-- This is also why lua/config/lazy.lua does not import the `editor.dial` extra: dial
-- binds <C-a>/<C-x>, which would be dead on arrival.

map({ "n", "v" }, "+", "<C-a>", { desc = "Increment number" })
map({ "n", "v" }, "-", "<C-x>", { desc = "Decrement number" })
map("v", "g+", "g<C-a>", { desc = "Increment as sequence" })
map("v", "g-", "g<C-x>", { desc = "Decrement as sequence" })

-- ---------------------------------------------------------------------------
-- 2. <leader>x — close buffer, mirroring C-a x
-- ---------------------------------------------------------------------------
-- Stock LazyVim uses <leader>x as its Trouble group. That group moves to <leader>X
-- (see lua/plugins/overrides.lua). The two <leader>x mappings LazyVim sets in core
-- rather than in a plugin spec are relocated here.
--
-- pcall: if a future LazyVim stops setting these, a hard error on every startup would
-- be a wildly disproportionate way to find out.
pcall(vim.keymap.del, "n", "<leader>xl")
pcall(vim.keymap.del, "n", "<leader>xq")

map("n", "<leader>Xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>Xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

-- Snacks.bufdelete closes the buffer while leaving the window and its layout intact.
-- Plain :bdelete would take the split down with it.
map("n", "<leader>x", function()
  Snacks.bufdelete()
end, { desc = "Close Buffer" })

-- ---------------------------------------------------------------------------
-- 3. <leader>z — zoom, mirroring C-a z
-- ---------------------------------------------------------------------------
-- LazyVim already has this on <leader>wm and leaves <leader>z unbound, so this is a
-- pure alias, not an override.

map("n", "<leader>z", function()
  Snacks.zen.zoom()
end, { desc = "Zoom Window" })

-- ---------------------------------------------------------------------------
-- 4. which-key group names
-- ---------------------------------------------------------------------------
-- The <leader>F mappings themselves live in lua/plugins/flutter.lua, next to the
-- plugin that provides them. Named here only so the which-key menu reads properly.

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({
        { "<leader>F", group = "flutter" },
        { "<leader>X", group = "diagnostics/quickfix" },
      })
    end
  end,
})
