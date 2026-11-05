# Neovim config — built on 0.12

Neovim's own plugin manager (`vim.pack`), built-in LSP and tree-sitter. No lazy.nvim,
no Mason. **10 plugins.** Rule: every plugin keeps its default keymaps; custom keys exist
only where a plugin ships no entry point.

```
init.lua
lua/options.lua      leader, clipboard, UI, indentation, wrap off
lua/plugins.lua      vim.pack.add(...) + per-plugin setup
lua/lsp.lua          server list, diagnostics, document colour, Kotlin JDK guard
lua/treesitter.lua   parser list, per-buffer highlighting
lua/format.lua       conform formatters per filetype
lua/keymaps.lua      entry points for fzf-lua, oil, conform, glow, sidekick
nvim-pack-lock.json  committed — pins every plugin revision
```

## Plugins

| Plugin | Role |
| --- | --- |
| fzf-lua | find files, find in files, buffers, LSP symbols (needs `fzf`, `fd`, `rg`) |
| oil.nvim | file explorer — edit the directory as a buffer |
| blink.cmp | autocomplete (prebuilt Rust matcher) |
| nvim-lspconfig | per-server defaults, used via `vim.lsp.config` / `vim.lsp.enable` |
| nvim-treesitter (`main`) | highlighting + indentation (needs `tree-sitter` CLI and `gcc`) |
| conform.nvim | format on save |
| render-markdown.nvim | markdown rendered in the buffer |
| sidekick.nvim | CLI AI agents in a terminal split: claude, codex, opencode, pi, kiro-cli |
| catppuccin (mocha) | colourscheme; auto-themes fzf-lua, blink, render-markdown, tree-sitter and LSP tokens |
| mini.icons | icons for the above, no devicons dependency |

## Keys (Space is leader)

| Keys | Action |
| --- | --- |
| `<leader>ff` `<leader><space>` | find files |
| `<leader>/` `<leader>sg` | find in files (live grep) |
| `<leader>,` `<leader>fr` `<leader>fg` | buffers / recent / git files |
| `<leader>ss` `<leader>sS` | LSP symbols: buffer / workspace |
| `<leader>sd` `<leader>sD` | diagnostics: buffer / workspace |
| `<leader>e` `<leader>E` | oil: current file's dir / cwd (`g?` inside oil for its keys) |
| `<leader>cf` | format |
| `<leader>mp` / `<leader>mt` | markdown preview in glow / toggle in-buffer render |
| `<leader>uw` | toggle word wrap (off by default) |
| `<leader>aa` `as` `ad` `at` `af` `av` `ap` | sidekick: toggle, select, detach, send this/file/selection, prompt |
| `<leader>ac` `ax` `ao` `ai` `ak` | sidekick: claude, codex, opencode, pi, kiro |
| `<C-s>` | save |
| `+` `-` | increment / decrement (tmux eats `<C-a>`) |

LSP keys are Neovim 0.11+ built-ins (`K gd gr gI gy gra grn gO ]d [d`). Completion keys
are blink's default preset (`<C-space> <C-n> <C-p> <C-y> <C-e> <C-k>`).

## Commands

```
:lua vim.pack.get()                 list installed plugins
:lua vim.pack.update()              update all (review the diff, then :w to confirm)
:checkhealth lsp                    what is attached, what is missing
```

## Language servers are external binaries

Nothing installs them. `lua/lsp.lua` enables a server only when its binary is on `PATH`.

| Language | Binary | Install |
| --- | --- | --- |
| Python | `basedpyright-langserver`, `ruff` | `npm i -g basedpyright`; `dnf install ruff` |
| Go | `gopls` | `go install golang.org/x/tools/gopls@latest` |
| JS/TS | `vtsls` | `npm i -g @vtsls/language-server typescript` |
| HTML/CSS/JSON | `vscode-*-language-server` | `npm i -g vscode-langservers-extracted` |
| YAML | `yaml-language-server` | `npm i -g yaml-language-server` |
| Markdown | `marksman` | GitHub release → `~/.local/bin` |
| Dart | `dart` | ships with the Flutter SDK |
| Kotlin | `kotlin-language-server` | GitHub release; **needs JDK ≤ 21** — it crashes on 25 |
| Lua | `lua-language-server` | `dnf` or GitHub release |

## Formatters (conform, on save; `<leader>cf` on demand)

| Files | Formatter | Indent |
| --- | --- | --- |
| Python | `ruff_format` + `ruff_organize_imports` | 4 spaces |
| Go | `gofumpt` + `goimports` | tabs |
| JS/TS, JSON, HTML, CSS, YAML, Markdown | `prettier` | 2 spaces |
| Dart | `dart format` | 2 spaces |
| Kotlin | `ktlint` (**not installed yet**) | 4 spaces |
| Lua | `stylua` | 2 spaces |
| Shell | `shfmt` | 2 spaces |

A missing formatter is skipped silently. A project's `.editorconfig` and its own
prettier/ruff/ktlint config override these defaults.
