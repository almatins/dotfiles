# Keymap — tmux + LazyVim

Daily-driver reference for Node.js, Flutter, Go, Kotlin and Python.

Every key below was verified against LazyVim's source, not written from memory. If a
mapping ever disagrees with reality, LazyVim is right and this file is stale — press
`<leader>` and wait, or `<leader>sk`, to see the live truth.

---

## 1. The layer model

Four programs compete for your keystrokes. They resolve top-down, and each owns a
distinct modifier so they never collide:

| Layer | Owns | Example |
| --- | --- | --- |
| GNOME Shell | `Super` | window switching |
| Ptyxis | `Ctrl+Shift` | `Ctrl+Shift+C` copy |
| **tmux** | **`Ctrl+A` prefix — and nothing else** | `C-a \|` split pane |
| **Neovim** | **`Space` leader + everything tmux ignores** | `Space \|` split window |

**tmux's root key-table is empty.** It intercepts exactly one key system-wide: `C-a`.
Every other keystroke reaches the program in the pane untouched. That is why `C-l`
still clears the screen in bash, `C-k` still kills a line, and LazyVim keeps all of
`C-h/j/k/l` for window navigation.

`Space` is a safe leader precisely because tmux never sees it.

### Why `Ctrl+A` is not the Neovim leader

It cannot be, while tmux uses it as a prefix — tmux consumes it before Neovim sees the
byte. The consequence you will actually feel: **Neovim's `<C-a>` (increment number) is
gone.** It is rehomed to `+`/`-` (see §4).

`C-a C-a` sends a literal `C-a` through to the pane, which is how bash keeps its
"beginning of line".

---

## 2. The shared verbs

The same letter means the same concept in both apps, one scope apart. tmux acts on
panes; Neovim acts on windows and buffers.

| Concept | tmux | Neovim |
| --- | --- | --- |
| Split right | `C-a \|` | `<leader>\|` |
| Split below | `C-a -` | `<leader>-` |
| Close | `C-a x` (pane) | `<leader>x` (buffer) |
| Zoom | `C-a z` | `<leader>z` |
| Find | `C-a f` (sessions) | `<leader>ff` (files) |

`|`, `-` and `z` are LazyVim defaults already. `<leader>x` and `<leader>ff` are the two
places we deviate from stock — see §4.

---

## 3. tmux

| Key | Action |
| --- | --- |
| `C-a \|` / `C-a -` | split right / below, in the current directory |
| `C-a h j k l` | move between panes |
| `C-a H J K L` | resize (hold to repeat) |
| `C-a x` / `C-a X` | close pane / window |
| `C-a z` | zoom pane |
| `C-a c` | new window, in the current directory |
| `C-a f` | session + window switcher |
| `C-a Tab` | last window |
| `C-a 1`…`9` | select window |
| `C-a d` | detach |
| `C-a r` | reload `~/.tmux.conf` |
| `C-a [` | copy mode — then `v` select, `y` copy, `Esc` cancel |
| `C-a C-a` | send a literal `C-a` (bash: beginning of line) |

Navigation is deliberately not repeatable: with `-r`, tmux would hold the prefix table
open and swallow the first letter of a word typed right after a jump. Resize is
repeatable, where that actually helps.

---

## 4. Our deviations from stock LazyVim

Four changes, and no more. Every extra override is a thing that breaks on upgrade.

| Key | Action | Why |
| --- | --- | --- |
| `+` / `-` | increment / decrement number | `<C-a>` belongs to tmux and never arrives. `<C-x>` follows it to `-` for symmetry. |
| `g+` / `g-` (visual) | increment / decrement as a sequence | replaces `g<C-a>` / `g<C-x>` |
| `<leader>x` | close buffer | mirrors `C-a x`. Stock LazyVim uses this as its Trouble group. |
| `<leader>X…` | Trouble / diagnostics list | moved aside to free `<leader>x` |

Consequences to remember:

- **Do not enable the `dial.nvim` extra.** It binds `<C-a>`/`<C-x>`, which tmux eats.
- Trouble moves: `<leader>Xx` diagnostics, `<leader>Xq` quickfix, `<leader>Xt` todos.
  Diagnostics are also on `<leader>sd` (picker) and `<leader>cd` (current line), so
  little is lost.
- `<leader>ff` rather than `<leader>f` for find-files — `<leader>f` is LazyVim's file
  group and is too useful to overwrite. "f = find" still holds.

`<C-s>` saves the file in LazyVim. That only works because `~/.bashrc` runs
`stty -ixon`; with flow control on, `C-s` freezes the terminal instead.

---

## 5. LazyVim — the daily 40

Enough to work all day. Press `<leader>` and pause for the rest; `<leader>sk` searches
every mapping.

### Moving around

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | move between **Neovim windows** (`C-a h/j/k/l` for **tmux panes**) |
| `<S-h>` / `<S-l>` | previous / next buffer (also `[b` / `]b`) |
| `s` / `S` | Flash jump / Flash Treesitter jump |
| `<C-i>` / `<C-o>` | jumplist forward / back — **never bind `<Tab>`, it is the same byte as `<C-i>`** |
| `<leader>,` | buffer picker |
| `` <leader>` `` | switch to the other buffer |

### Finding

| Key | Action |
| --- | --- |
| `<leader><space>` | find files (project root) |
| `<leader>ff` | find files (project root) |
| `<leader>fr` | recent files |
| `<leader>fg` | find git-tracked files |
| `<leader>/` | live grep (project root) |
| `<leader>sw` | grep the word under the cursor |
| `<leader>sg` | grep (project root) |
| `<leader>sr` | search and replace across the project (grug-far) |
| `<leader>ss` | LSP symbols in this file |
| `<leader>sS` | LSP symbols across the workspace |
| `<leader>sk` | search all keymaps |
| `<leader>sh` | search help |
| `<leader>e` | file explorer |

### Code — the same six keys in every language

| Key | Action |
| --- | --- |
| `gd` | go to definition |
| `gr` | references |
| `gI` | go to implementation |
| `gy` | go to type definition |
| `K` | hover docs |
| `gK` | signature help (`<C-k>` in insert mode) |
| `<leader>ca` | code action |
| `<leader>cr` | rename symbol |
| `<leader>cR` | rename file (and fix imports) |
| `<leader>cf` | format buffer |
| `<leader>co` | organize imports |
| `<leader>cd` | diagnostics for this line |
| `<leader>cl` | LSP info — *what is attached to this buffer?* |
| `<leader>cm` | Mason — install/inspect language servers |
| `]d` / `[d` | next / previous diagnostic |
| `]e` / `[e` | next / previous **error** |
| `<leader>Xx` | full diagnostics list (Trouble — moved, see §4) |
| `gcc` / `gc` | comment line / comment motion |
| `<A-j>` / `<A-k>` | move line or selection up / down |

### Git

| Key | Action |
| --- | --- |
| `<leader>gs` | git status |
| `<leader>gb` | blame current line |
| `<leader>gd` | diff hunks |
| `<leader>gl` | git log |
| `<leader>gf` | history of the current file |
| `<leader>gB` | open this line on GitHub |

### Session and housekeeping

| Key | Action |
| --- | --- |
| `<C-s>` | save |
| `<leader>x` | close buffer *(our override)* |
| `<leader>\|` / `<leader>-` | split right / below |
| `<leader>z` | zoom window |
| `<leader>wd` | close window |
| `<leader>qq` | quit all |
| `<leader>qs` | restore last session |
| `<leader>l` | Lazy — plugin manager |
| `<leader>uf` | toggle format-on-save |
| `<Esc>` | clear search highlight |

---

## 6. Per-language

All five language servers install themselves through Mason on first open — you do not
install them by hand. `<leader>cl` tells you what actually attached; `<leader>cm` opens
Mason if something did not.

### Node.js / TypeScript — `lang.typescript`

Server is **vtsls**. Beyond the universal keys above:

| Key | Action |
| --- | --- |
| `gD` | go to *source* definition (through the `.d.ts`, to the real code) |
| `gR` | all references to this **file** |
| `<leader>cM` | add all missing imports |
| `<leader>cD` | fix all auto-fixable diagnostics in the file |
| `<leader>cV` | select the TypeScript version (workspace vs bundled) |

`gD` is the one worth learning: plain `gd` on a library symbol lands you in a type
declaration, `gD` takes you to the implementation.

For the Simpel backend, run the API in a tmux pane (`C-a -` for a split below) and keep
Neovim in the top pane. `<leader>Xx` after a save shows every type error at once.

### Flutter / Dart — `lang.dart` + `flutter-tools.nvim`

**LazyVim's Dart extra gives you a language server and nothing else** — no device
picker, no hot reload, no `flutter run`. `flutter-tools.nvim` fills that gap and is
mapped under `<leader>F`:

| Key | Action |
| --- | --- |
| `<leader>Fr` | `flutter run` on the selected device |
| `<leader>FR` | hot **restart** |
| `<leader>Fq` | quit the running app |
| `<leader>Fd` | pick a device |
| `<leader>Fe` | pick an emulator |
| `<leader>Fo` | widget outline (invaluable in deep widget trees) |
| `<leader>FD` | open DevTools |

Hot **reload** happens automatically on save. Widget-tree work: `<leader>Fo` for the
outline, `<leader>ca` on a widget for "wrap with…" / "extract widget".

All five frontends are Flutter Web, so the device you want is usually Chrome:
`<leader>Fd` → Chrome, then `<leader>Fr`.

### Go — `lang.go`

Server **gopls**, formatting via **gofumpt** + **goimports**, debugging via **Delve**,
tests via **neotest-go**. Imports are fixed on save; `<leader>co` forces it.

| Key | Action |
| --- | --- |
| `<leader>tr` | run nearest test |
| `<leader>tt` | run all tests in the file |
| `<leader>ts` | test summary panel |
| `<leader>td` | debug nearest test |
| `<leader>db` | toggle breakpoint |
| `<leader>dc` | run / continue |

*(the `<leader>t` and `<leader>d` groups require the `test` and `dap` extras)*

### Kotlin — `lang.kotlin`

Server **kotlin_language_server**, linting via **ktlint**. Java is on your PATH, which
the server needs.

Set expectations: the Kotlin language server is much weaker than the TypeScript or Go
ones. Completion and go-to-definition work; deep Android/Gradle integration does not.
For Android-specific work, Android Studio remains the better tool — Neovim is good for
editing Kotlin, not for driving the Android build.

### Python — `lang.python`

Server **basedpyright**, linting and formatting via **ruff**.

| Key | Action |
| --- | --- |
| `<leader>cv` | select the virtualenv — **do this first in any new project**, or every import resolves as missing |
| `<leader>dPt` | debug the test method under the cursor |
| `<leader>dPc` | debug the test class under the cursor |

---

## 7. Toolchain

Present: `git`, `rg`, `gcc`, `node`, `npm`, `go`, `dart`, `flutter`, `java`, `python3`.

Needed:

```sh
sudo dnf install fd-find fzf lazygit
```

- **fd** — what the picker uses to walk files; without it, finding is slower.
- **fzf** — used by some pickers and by `lazygit`.
- **lazygit** — optional, but LazyVim's git integration is built around it.

**A Nerd Font is not optional.** LazyVim's UI is icon-driven; without one, every icon
renders as a tofu box and the editor looks broken:

```sh
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip && rm JetBrainsMono.zip
fc-cache -f
```

Then point Ptyxis at it:

```sh
gsettings set org.gnome.Ptyxis use-system-font false
gsettings set org.gnome.Ptyxis font-name 'JetBrainsMono Nerd Font 11'
```

Language servers install themselves via Mason on first file open. If one does not,
`<leader>cl` shows what attached and `<leader>cm` opens Mason.
