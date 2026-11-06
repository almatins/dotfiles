# Keymaps — Alacritty + Neovim

Complete key reference for the terminal (Alacritty 0.17.0) and the editor (Neovim 0.12).
Verified on 2026-11-06 against the live setup, not from memory.

## Legend

| Mark | Meaning |
| --- | --- |
| ✅ | **Default.** Shipped by Alacritty, Neovim or a plugin and left exactly as is. |
| ➕ | **Added.** A new key on a combination that had no default, so nothing was changed. |
| ⚠️ | **Changed from default.** A key that replaces or extends a built-in default. |

Plugin keys count as ✅ when the plugin binds them itself, and as ➕ when the plugin ships
no keys and we bind the ones its README suggests. A plugin key that replaces a Neovim
built-in is marked ⚠️ even though the plugin set it.

## Verdict

- **Alacritty: 0 changes.** `~/.config/alacritty/alacritty.toml` has no `[keyboard]` or
  `[mouse]` section, so every key and mouse binding is Alacritty's default.
- **Neovim: defaults are kept.** A clean `nvim --clean` has 101 default mappings. With this
  config loaded, 100 are unchanged and 1 differs (select-mode `<C-s>`, §2.1). No default was
  deleted.
- **Everything else is either added on a free key (➕) or listed in §2.1 (⚠️).**

How it was checked: every mapping (global and per-buffer, in all modes) was dumped from a
running Neovim with its defining file, and compared against the dump from `nvim --clean`.
Built-in commands that are not mappings (visual `S`, `<Space>`) were checked by hand.

To see where any key comes from yourself: `:verbose map <key>` (or `:verbose imap <key>`),
or `<leader>sk` to search every mapping, or `<leader>?` for the current buffer's keys.

---

## 1. Alacritty — all ✅ default

Config: `~/.config/alacritty/alacritty.toml` (appearance only: font, colours, opacity,
padding). It is not in this repo yet.

### 1.1 Everyday keys

| Key | Action | Mode |
| --- | --- | --- |
| `Ctrl+Shift+C` | Copy | ✅ |
| `Ctrl+Shift+V` | Paste | ✅ |
| `Shift+Insert` | Paste the primary selection | ✅ |
| `Ctrl+Shift+F` | Search forward | ✅ |
| `Ctrl+Shift+B` | Search backward | ✅ |
| `Ctrl+=` or `Ctrl++` | Increase font size | ✅ |
| `Ctrl+-` | Decrease font size | ✅ |
| `Ctrl+0` | Reset font size | ✅ |
| `Ctrl+L` | Clear the log notice and send `^L` to the program | ✅ |
| `Shift+PageUp` / `Shift+PageDown` | Scroll history by a page | ✅ only on the main screen |
| `Shift+Home` / `Shift+End` | Scroll to the top / bottom | ✅ only on the main screen |
| `Ctrl+Shift+Space` | Toggle vi mode | ✅ |

"Only on the main screen" means the key does nothing in programs that use the alternate
screen (Neovim does), so Neovim receives `Shift+PageUp` and friends itself.

### 1.2 Mouse

| Binding | Action |
| --- | --- |
| Right click, `Ctrl`+Right click | Expand the selection |
| Middle click (not in vi mode) | Paste the primary selection |

### 1.3 Vi mode (`Ctrl+Shift+Space`) — ✅ default

Keyboard-driven selection and scrollback. Leave with `i`, `Ctrl+C` or `Ctrl+Shift+Space`;
`Esc` only clears the selection.

| Group | Keys |
| --- | --- |
| Move | `h j k l`, arrow keys, `0` first, `$` last, `^` first non-blank, `Home` `End` |
| Words | `w` `b` `e` (semantic), `W` `B` `E` (whitespace), `%` matching bracket |
| Paragraphs | `{` `}` |
| Screen | `H` top, `M` middle, `L` bottom of the screen, `z` centre on the cursor |
| Scroll | `g` top, `G` bottom, `Ctrl+B` / `Ctrl+F` page, `Ctrl+U` / `Ctrl+D` half page, `Ctrl+Y` / `Ctrl+E` line |
| Select | `v` characters, `V` lines, `Ctrl+V` block, `Alt+V` semantic, `Esc` clear |
| Copy | `y` copy and clear the selection, `Y` copy to the end of the line |
| Open | `Enter` opens a link or path under the cursor |
| Find in a line | `f` `F` `t` `T`, then `;` next and `,` previous |
| Search | `/` forward, `?` backward, `n` next, `N` previous, `*` / `#` word under the cursor |

### 1.4 Search bar — ✅ default

| Keys | Action |
| --- | --- |
| `Enter` | Confirm, then `Enter` again jumps to the next match |
| `Esc` or `Ctrl+C` | Cancel |
| `Ctrl+U` | Clear the line |
| `Ctrl+W` | Delete the previous word |
| `Ctrl+P` / `Up` | Previous history entry |
| `Ctrl+N` / `Down` | Next history entry |

### 1.5 Keys Alacritty takes before Neovim sees them

`Ctrl+Shift+C/V/F/B`, `Ctrl+0`, `Ctrl+=`, `Ctrl++`, `Ctrl+-`, `Shift+Insert` and
`Ctrl+Shift+Space` never reach Neovim. `Ctrl+-` and `Ctrl+=` are the ones you could
plausibly want in an editor.

---

## 2. Neovim

Space is the leader. Mark meanings are in the legend above.

### 2.1 ⚠️ Changed from default

This is the complete list of places where a key behaves differently from stock Neovim.

| Key | Mode | Stock behaviour | Now | Set by |
| --- | --- | --- | --- | --- |
| `<Space>` | normal, visual | Move right one character | Leader prefix. Use `l` for the motion. | ours, `options.lua` |
| `<C-s>` | select | Show signature help | Save the file. Select mode is rare (snippet placeholders); insert mode keeps the stock signature help. | ours, `keymaps.lua` |
| `S` | visual | Change the selected lines | Surround the selection | nvim-surround default |
| `(` `[` `{` `"` `'` `` ` `` | insert | Type the character | Also inserts the closing character | nvim-autopairs default |
| `)` `]` `}` | insert | Type the character | Skips over an existing closer | nvim-autopairs default |
| `<BS>` | insert | Delete one character | Deletes both halves of an empty pair | nvim-autopairs default |
| `<CR>` | insert | New line | Same, plus indents between a pair; confirms a completion | nvim-autopairs default |
| `<C-e>` `<C-y>` | insert | Insert the character below / above | Dismiss / accept the completion menu | blink.cmp default |
| `<C-n>` `<C-p>` `<Down>` `<Up>` | insert | Stock completion, cursor movement | Move through blink's menu | blink.cmp default |
| `<C-k>` | insert | Digraph entry | Signature help | blink.cmp default |
| `<C-Space>` | insert | Insert the last inserted text and leave insert mode (`<C-@>`) | Open the completion menu | blink.cmp default |
| `<Tab>` `<S-Tab>` | insert, select | Snippet jump | Snippet jump (same action) | blink.cmp default |
| `]c` `[c` | normal, in git-tracked files | Diff-mode hunk jump only | Git hunk jump; in diff windows falls back to the stock jump | ours, `git.lua` (gitsigns README) |

Every blink.cmp key has a `fallback`: when blink has nothing to do (no menu open, no
signature available) the stock behaviour runs. The same keys are active in the `:` command
line as well (`<C-Space>` `<C-n>` `<C-p>` `<C-y>` `<C-e>` `<Tab>` `<S-Tab>` `<Left>`
`<Right>` `<End>`).

**Only inside oil buffers.** Oil rebinds these there; elsewhere they are stock:

| Key | Stock | In oil |
| --- | --- | --- |
| `-` | Up one line, first non-blank | Go to the parent directory |
| `<CR>` | Down one line | Open the entry |
| `` ` `` | Jump to a mark | `:cd` to the oil directory |
| `gs` | Go to sleep | Change the sort order |
| `<C-h>` `<C-l>` `<C-p>` `<C-t>` `<C-c>` | Left, redraw, up, tag-pop, interrupt | Open in horizontal split, refresh, preview, open in tab, close oil |

`<C-s>` (open in vertical split) is also oil's, and overrides the global save inside oil;
use `:w` there to apply your edits.

**Triggers that do not change anything.** which-key wraps `<Space>`, `g`, `z`, `[`, `]`,
`<C-w>`, `"`, `'`, `` ` `` and insert-mode `<C-r>` so it can show a popup, then replays
the key. Behaviour is unchanged.

### 2.2 ➕ Added keys

All are on free keys: the leader namespace, or combinations with no stock meaning.

#### Files, finding, searching (fzf-lua — ships no global keys)

| Key | Action |
| --- | --- |
| `<leader>ff` `<leader><space>` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Git files |
| `<leader>,` | Buffers |
| `<leader>/` `<leader>sg` | Find in files (live grep) |
| `<leader>sw` | Grep the word under the cursor, or the selection |
| `<leader>sd` `<leader>sD` | Diagnostics: buffer / workspace |
| `<leader>ss` `<leader>sS` | LSP symbols: buffer / workspace |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help |
| `<leader>sr` | Resume the last search |
| `<leader>e` | File explorer in the current file's directory (oil) |
| `<leader>E` | File explorer in the working directory (oil) |

#### Code, markdown, window, UI

| Key | Action |
| --- | --- |
| `<leader>cf` | Format the buffer or selection (conform) |
| `<leader>mp` | Markdown preview in glow, following the wrap setting |
| `<leader>mt` | Toggle in-buffer markdown rendering |
| `<leader>uw` | Toggle word wrap (off by default) |
| `<leader>\|` `<leader>-` | Split right / below |
| `<leader>wd` | Close the window |
| `<leader>?` | Keymaps of the current buffer (which-key) |
| `<C-s>` | Save, in normal and visual mode |

#### Git

| Key | Action |
| --- | --- |
| `<leader>gg` | Lazygit in a floating terminal |
| `<leader>gs` `gc` `gl` `gb` `gS` | Status, commits, this file's log, branches, stash (fzf-lua) |
| `]c` `[c` | Next / previous hunk (also in §2.1) |
| `<leader>hs` `<leader>hr` | Stage / reset hunk; works on a visual selection too |
| `<leader>hS` `<leader>hR` | Stage / reset the whole buffer |
| `<leader>hp` `<leader>hi` | Preview the hunk, in a float / inline |
| `<leader>hb` | Blame the line |
| `<leader>hd` `<leader>hD` | Diff against the index / the last commit |
| `<leader>hq` `<leader>hQ` | Hunks to quickfix: this file / all files |
| `<leader>tb` `<leader>tw` | Toggle line blame / word diff |
| `ih` (operator, visual) | Hunk text object, e.g. `vih` |

The hunk keys exist only inside git-tracked files. They are gitsigns' README set, bound
in `lua/git.lua`.

#### AI agents (sidekick — ships no global keys; README set plus one key per agent)

| Key | Action |
| --- | --- |
| `<leader>aa` | Toggle the last-used agent |
| `<leader>as` | Select an agent |
| `<leader>ad` | Detach the session |
| `<C-.>` | Focus the agent (normal, insert, visual, terminal). Needs a terminal that sends `Ctrl+.`. |
| `<leader>ac` `ax` `ao` `ai` `ak` | claude, codex, opencode, pi, kiro |
| `<leader>at` | Send "this" (normal, visual) |
| `<leader>af` | Send the file |
| `<leader>av` | Send the visual selection |
| `<leader>ap` | Pick a prompt (normal, visual) |

#### Sessions (persistence — ships no keys; README set)

| Key | Action |
| --- | --- |
| `<leader>qs` | Restore the session for this directory |
| `<leader>qS` | Pick a session |
| `<leader>ql` | Restore the last session |
| `<leader>qd` | Do not save the current session |

### 2.3 ✅ Plugin default keys, kept as shipped

| Plugin | Keys |
| --- | --- |
| nvim-surround | `ys{motion}{char}` add, `yss` line, `yS` / `ySS` on new lines, `ds{char}` delete, `cs{old}{new}` change, `cS` change on new lines, visual `S` / `gS` wrap, insert `<C-g>s` / `<C-g>S` |
| oil (inside oil buffers) | `g?` help, `<CR>` open, `-` parent, `_` working directory, `` ` `` `:cd`, `g~` tab-local `:cd`, `g.` toggle hidden, `gs` sort, `g\` trash, `gx` external, `<C-p>` preview, `<C-l>` refresh, `<C-c>` close, `<C-s>` vertical split, `<C-h>` split, `<C-t>` tab |
| blink.cmp (insert) | `<C-space>` open, `<C-n>` `<C-p>` `<Down>` `<Up>` move, `<C-y>` accept, `<C-e>` dismiss, `<C-b>` `<C-f>` docs, `<C-k>` signature, `<Tab>` `<S-Tab>` snippets |
| nvim-autopairs (insert) | pairing on `( [ { " ' \``, `<BS>`, `<CR>` |
| which-key | popup after `<leader>` or `g`, `z`, `[`, `]`, `<C-w>` and registers (`"`, `<C-r>`); `<BS>` goes back, `<Esc>` closes |
| blink.cmp (insert, extra) | `<C-b>` `<C-f>` scroll the documentation pane. These have no stock meaning in insert mode, so they change nothing. |
| render-markdown, lualine, conform | no keys of their own |

#### Inside fzf-lua pickers (fzf-lua and fzf defaults)

| Keys | Action |
| --- | --- |
| type | Fuzzy filter |
| `<Down>` `<Up>`, `<C-j>` `<C-k>`, `<C-n>` `<C-p>` | Move the selection |
| `<CR>` | Open |
| `<C-s>` `<C-v>` `<C-t>` | Open in a horizontal split / vertical split / tab |
| `<Tab>` | Mark the item and move down (multi-select) |
| `<M-a>` | Toggle all |
| `<M-q>` | Send the marked items to quickfix |
| `<C-x>` | In the buffer picker: delete the buffer |
| `<F4>` `<F3>` | Toggle the preview / preview wrap |
| `<S-Down>` `<S-Up>` | Scroll the preview by a page |
| `<C-f>` `<C-b>` | Half page down / up in the list |
| `<C-u>` | Clear the typed query |
| `<M-g>` | First item |
| `<M-i>` `<M-h>` `<M-f>` | In file pickers: toggle ignore / hidden / follow symlinks |
| `<Esc>` `<C-c>` | Close |

The `<M-…>` keys are Alt combinations; some terminals do not deliver them.

#### In the glow preview (`<leader>mp`)

The preview is `less` (wrap off) or glow's own pager (wrap on). `q` quits. With wrap off,
`<Left>` and `<Right>` scroll sideways.

### 2.4 ✅ Neovim built-in defaults (0.12)

Unchanged, except where §2.1 says otherwise.

| Keys | Action |
| --- | --- |
| `<C-]>` `<C-w>]` | **Go to definition / in a split.** With an LSP attached, Neovim points `tagfunc` at the server, so the tag keys follow the language server. `<C-t>` jumps back. |
| `K` | Hover (LSP; buffer-local when a server attaches) |
| `grn` `gra` `grr` `gri` `grt` `grx` | Rename, code action (normal and visual), references, implementation, type definition, run code lens |
| `gd` `gD` | **Not LSP.** Vim's own text search for the local / global declaration in the current file only. It cannot follow an import into another file; use `<C-]>` for that. |
| `gO` | Document symbols outline |
| `<C-s>` (insert) | Signature help |
| `]d` `[d` `]D` `[D` | Next / previous / last / first diagnostic |
| `<C-w>d` `<C-w><C-d>` | Show diagnostics under the cursor |
| `gcc` `gc{motion}` `gc` (visual) `gc` (operator) | Toggle comment |
| `gx` | Open the path or URL under the cursor |
| `an` `in` `]n` `[n` `]N` `[N` | Tree-sitter selection: outer / inner node, next / previous node, sibling (visual, operator) |
| `]b` `[b` `]B` `[B` | Next / previous / last / first buffer |
| `]a` `[a` `]A` `[A` | Argument list |
| `]q` `[q` `]Q` `[Q` `]<C-q>` `[<C-q>` | Quickfix list |
| `]l` `[l` `]L` `[L` `]<C-l>` `[<C-l>` | Location list |
| `]t` `[t` `]T` `[T` `]<C-t>` `[<C-t>` | Tags |
| `]<Space>` `[<Space>` | Add an empty line below / above |
| `%` `[%` `]%` `g%` `a%` | Matchit: jump between matching pairs and tags |
| `Y` `&` `<C-l>` | Yank to end of line, repeat `:s`, clear and redraw |
| `<Tab>` `<S-Tab>` (insert, select) | Jump in an active snippet |
| `<C-w>` `<C-u>` (insert) | Delete word / line, undo-friendly |
| `*` `#` `@` `Q` (visual) | Search selection, search backward, run macro, repeat macro |
| `[[` `]]` `[]` `][` `[m` `]m` `[M` `]M` | Jump between functions and classes (Python, Go, Markdown and other filetypes that define them) |
| `:packadd nvim.undotree`, `:packadd nvim.difftool` | Built-in undo tree and file/directory diff, opt-in |

The standard Vim motions and operators (`hjkl`, `w b e`, `d c y p`, `u <C-r>`, `/ ? n N`,
`<C-o> <C-i>`, `<C-^>`, and the rest) are untouched.

---

## 3. Inside tmux

This document covers Alacritty and Neovim only. If you run Neovim inside tmux, tmux
consumes `Ctrl+A` as its prefix, so Neovim never sees `<C-a>` (increment number). The tmux
bindings are in `tmux/.tmux.conf`; `KEYMAP.md` in the repo root is an older reference that
still describes the previous Neovim setup and is out of date for Neovim.
