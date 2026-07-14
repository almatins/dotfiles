-- Neovim config — companion to ~/.tmux.conf.
--
-- Division of labour: tmux owns the world OUTSIDE the editor (panes, windows,
-- sessions) behind the C-a prefix. Neovim owns the world INSIDE it behind the
-- Space leader. The same mnemonic means the same concept at each scope:
--
--     concept      tmux          neovim
--     split right  C-a |         <leader> |
--     split below  C-a -         <leader> -
--     close        C-a x         <leader> x
--     zoom         C-a z         <leader> z
--     find         C-a f         <leader> f
--
-- Space is a safe leader precisely because tmux never sees it: tmux's root
-- key-table is empty, so C-a is the only key it intercepts. Nothing here can
-- collide with it.

-- Must be set before any plugin loads, or plugin mappings bind to the old leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options')
require('plugins')
require('lsp')
require('keymaps')
