# Keymap — tmux + Neovim

Daily-driver reference for Node.js, Flutter, Go, Kotlin and Python.

Every key below is defined in `nvim/.config/nvim/lua/keymaps.lua` or is a Neovim
built-in. If a mapping ever disagrees with reality, press `<leader>` and wait
(`mini.clue`), or `<leader>sk` to grep every mapping — those are the live truth.

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
still clears the screen in bash, `C-k` still kills a line, and Neovim keeps all of
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

All five are explicit in `lua/keymaps.lua` — nothing here is inherited from a distro.

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

## 4. Deviations from stock Neovim

Five changes, and no more. Everything else is a stock Neovim 0.11+ binding, because
every override is a thing that can break on upgrade.

| Key | Action | Why |
| --- | --- | --- |
| `+` / `-` | increment / decrement number | `<C-a>` belongs to tmux and never arrives. `<C-x>` follows it to `-` for symmetry. |
| `g+` / `g-` (visual) | increment / decrement as a sequence | replaces `g<C-a>` / `g<C-x>` |
| `<leader>x` | close buffer | mirrors `C-a x`. Keeps the window layout intact (mini.bufremove). |
| `<leader>X…` | diagnostics / quickfix lists | `<leader>x` needed to mean "close" |
| `gK` / `C-k` | signature help | 0.11 puts it on `<C-s>` in insert mode; `<C-s>` is save here |

Consequences to remember:

- **No dial.nvim.** It binds `<C-a>`/`<C-x>`, which tmux eats.
- `<leader>Xx` is the diagnostics list (loclist), `<leader>Xq` the quickfix list.
- `<C-s>` saves the file. That only works because `~/.bashrc` runs `stty -ixon`; with
  flow control on, `C-s` freezes the terminal.

---

## 5. The daily keys

### Moving around

| Key | Action |
| --- | --- |
| `<C-h/j/k/l>` | move between **Neovim windows** (`C-a h/j/k/l` for **tmux panes**) |
| `<S-h>` / `<S-l>` | previous / next buffer (also `[b` / `]b`) |
| `<leader>bb` | alternate buffer |
| `<leader>,` | buffer picker |
| `<C-i>` / `<C-o>` | jumplist forward / back — **never bind `<Tab>`, it is the same byte as `<C-i>`** |
| `<A-j>` / `<A-k>` | move line or selection up / down (mini.move) |

### Finding

| Key | Action |
| --- | --- |
| `<leader><space>` | find files |
| `<leader>ff` | find files |
| `<leader>fr` | recent files |
| `<leader>fg` | find git-tracked files |
| `<leader>/` | live grep |
| `<leader>sg` | live grep |
| `<leader>sw` | grep the word under the cursor |
| `<leader>sd` | diagnostics picker |
| `<leader>ss` | LSP symbols in this file |
| `<leader>sS` | LSP symbols across the workspace |
| `<leader>sk` | search all keymaps |
| `<leader>sh` | search help |
| `<leader>e` | file explorer (mini.files) |
| `<leader>E` | reveal current file in the explorer |

Pickers run from the **current working directory**, not a per-project root: start
Neovim in the repo you mean to search. `fd` and `rg` are used when present.

### Code — the same keys in every language

| Key | Action |
| --- | --- |
| `gd` | go to definition |
| `gr` | references |
| `gI` | go to implementation |
| `gy` | go to type definition |
| `gD` | go to declaration |
| `K` | hover docs |
| `gK` / `<C-k>` | signature help (normal / insert) |
| `<leader>ca` | code action |
| `<leader>cr` | rename symbol |
| `<leader>co` | organize imports |
| `<leader>cf` | format buffer (format-on-save is on by default) |
| `<leader>cd` | diagnostics for this line |
| `<leader>cl` | LSP info — *what is attached to this buffer?* (`:checkhealth lsp`) |
| `]d` / `[d` | next / previous diagnostic |
| `]h` / `[h` | next / previous git hunk |
| `<leader>Xx` | full diagnostics list |
| `gcc` / `gc` | comment line / comment motion |

There is no `<leader>cm` any more: Mason is gone. Servers are ordinary binaries on
`PATH` (see §6).

### Git

| Key | Action |
| --- | --- |
| `<leader>gs` | stage hunk |
| `<leader>gr` | reset hunk |
| `<leader>gp` | preview hunk |
| `<leader>gb` | blame current line |
| `<leader>gd` | diff this file |
| `]h` / `[h` | next / previous hunk |

There is no git-status/log UI plugin. `lazygit` is installed — run it in a tmux pane.

### Session and housekeeping

| Key | Action |
| --- | --- |
| `<C-s>` | save |
| `<leader>x` | close buffer *(our override)* |
| `<leader>\|` / `<leader>-` | split right / below |
| `<leader>z` | zoom window |
| `<leader>wd` | close window |
| `<leader>qq` | quit all |
| `<leader>e` | file explorer |
| `<Esc>` | clear search highlight |
| `:mksession` | save a session (no persistence plugin) |

---

## 6. Per-language

Language servers are **external binaries**, not plugins. `lua/lsp.lua` enables a server
only when its binary is on `PATH`, so a missing one is silent instead of erroring on
every buffer. Install one and it works on the next launch — no config edit.

| Language | Server | Installed at |
| --- | --- | --- |
| Lua | `lua-language-server` | `~/.local/bin` (3.19.2) |
| TypeScript / JS | `vtsls` | npm global |
| Go | `gopls` | `~/go/bin` (Go 1.27 at `~/.local/go`) |
| Python | `basedpyright-langserver` | `~/.local/bin` (uv tool) |
| Dart / Flutter | `dart` (via flutter-tools) | Flutter SDK |
| Kotlin | `kotlin-language-server` | `~/.local/bin`, **JDK 21 required** |
| JSON | `vscode-json-language-server` | npm global |
| YAML | `yaml-language-server` | npm global |
| Bash | `bash-language-server` | npm global |
| Docker | `docker-langserver` | npm global |

### Node.js / TypeScript

Server is **vtsls**. `gd` on a library symbol lands in a `.d.ts`; `gD` takes you to the
declaration. Formatting is prettier.

> **`.vue` files have no dedicated server.** vtsls handles `<script lang="ts">` but not
> template expression intelligence. If that becomes painful, add
> `vue-language-server` and point vtsls at the Vue TS plugin — it is the one language
> gap left by the plugin cut.

For the backend, run the API in a tmux pane (`C-a -` for a split below) and keep Neovim
in the top pane. `<leader>Xx` after a save shows every type error at once.

### Flutter / Dart

flutter-tools starts **dartls** itself — `lua/lsp.lua` deliberately does not enable
`dartls`, because two clients on one buffer make `gd` a coin flip.

| Key | Action |
| --- | --- |
| `<leader>Fr` | `flutter run` on the selected device |
| `<leader>FR` | hot **restart** |
| `<leader>Fl` | hot **reload** (also happens on save) |
| `<leader>Fq` | quit the running app |
| `<leader>Fd` | pick a device |
| `<leader>Fe` | pick an emulator |
| `<leader>Fo` | widget outline (invaluable in deep widget trees) |
| `<leader>FD` | open DevTools |
| `<leader>FL` | toggle the dev log pane |
| `<leader>Fs` | restart dartls |

All the frontends are Flutter Web, so the device you want is usually Chrome:
`<leader>Fd` → Chrome, then `<leader>Fr`.

### Go

Server **gopls**, formatting via **gofumpt** + **goimports** (skipped when a binary is
missing). Tests and debugging are not wired into the editor — use a tmux pane, or add
`neotest`/`nvim-dap` back deliberately.

### Kotlin

> **Why this needs a special JDK.** kotlin-language-server bundles a Kotlin compiler
> whose IntelliJ version parser cannot parse a Java major version above 21, and dies
> during `initialize` on any `.kt` buffer. Fedora 44 ships only OpenJDK 25, and
> **Android Studio now bundles 25 as well** (`~/.local/opt/android-studio/jbr`).
>
> The fix is a JDK 17–21 in `~/.local/jdk`. Temurin 21 is installed there and verified
> working; `lua/lsp.lua` finds it by path and passes it as `JAVA_HOME`. If none is
> found the server is left disabled rather than left to crash on every buffer.
>
> KLS also rejects an empty `initializationOptions`: Lua encodes `{}` as JSON `[]` and
> Gson expects an object. The config passes a real `storagePath` to avoid that.

Set expectations: KLS is much weaker than vtsls or gopls. Completion and
go-to-definition work; deep Android/Gradle integration does not. For Android work,
Android Studio remains the better tool — Neovim is good for editing Kotlin, not for
driving the build.

### Python

Server **basedpyright**, formatting and import sorting via **ruff**. basedpyright
auto-detects a project `.venv`; if imports resolve as missing, point it at the
virtualenv with `pyrightconfig.json` (`venvPath` / `venv`) rather than a plugin.

---

## 7. Toolchain — verified state

Neovim 0.12.6, **8 plugins**, ~36 ms startup, 30 treesitter parsers.

| Language | LSP verified attaching | Formatter |
| --- | --- | --- |
| Lua | `lua_ls` | stylua 2.6.0 |
| TypeScript | `vtsls` | prettier |
| JSON | `jsonls` | prettier |
| YAML | `yamlls` | prettier |
| Bash | `bashls` | shfmt 3.14.1 |
| Dockerfile | `dockerls` | — |
| Go | `gopls` | gofumpt + goimports |
| Python | `basedpyright` | ruff 0.17.3 |
| Dart | `dartls` (exactly once) | `dart format` |
| Kotlin | `kotlin_language_server` | — |

Restart Neovim after installing a binary; `:checkhealth lsp` lists what is enabled and
what is missing.
