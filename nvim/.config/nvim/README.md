# Neovim config — minimal, built on 0.12

From-scratch config on Neovim's own plugin manager. No LazyVim, no lazy.nvim, no
Mason: **8 plugins**, and the rest is built in.

```
init.lua
lua/options.lua      leader, clipboard, UI, indentation
lua/plugins.lua      vim.pack.add(...) + per-plugin setup
lua/lsp.lua          server list, completion, diagnostics, document colour
lua/treesitter.lua   parser list, per-buffer highlighting
lua/format.lua       conform formatters per filetype
lua/keymaps.lua      the tmux-mirrored keymap
nvim-pack-lock.json  committed — pins every plugin revision
```

## Plugins

| Plugin | Why |
| --- | --- |
| tokyonight.nvim | colourscheme |
| mini.nvim | icons, statusline, pick, extra, files, clue, ai, pairs, surround, bufremove, move, misc |
| nvim-lspconfig | server configs, consumed through `vim.lsp.config` / `vim.lsp.enable` |
| nvim-treesitter (`main`) | highlighting and indentation |
| gitsigns.nvim | hunks, blame, staging |
| conform.nvim | format on save |
| flutter-tools.nvim | run, hot reload, devices, outline, DevTools |
| plenary.nvim | flutter-tools dependency |

Replaced by built-ins: `blink.cmp` → `vim.lsp.completion`, `lualine`/`bufferline` →
`mini.statusline`, `which-key` → `mini.clue`, `persistence` → `:mksession`,
`nvim-lint` → LSP diagnostics.

## Commands

```
:lua vim.pack.get()                 list installed plugins
:lua vim.pack.update()              update all
:lua vim.pack.update({ 'mini.nvim' })
:checkhealth lsp                    what is attached, what is missing
```

## Language servers are external binaries

Nothing installs them for you. `lua/lsp.lua` enables a server only when its binary is
on `PATH`, so a missing one is silent instead of an error on every buffer.

| Language | Binary | Install |
| --- | --- | --- |
| Lua | `lua-language-server` | GitHub release → `~/.local/bin` |
| TypeScript/JS | `vtsls` | `npm i -g @vtsls/language-server` |
| Go | `gopls` | Go 1.27 at `~/.local/go`; `go install golang.org/x/tools/gopls@latest` → `~/go/bin` |
| Python | `basedpyright-langserver` | `uv tool install basedpyright` |
| Dart/Flutter | `dart` | already on PATH via the Flutter SDK |
| Kotlin | `kotlin-language-server` | GitHub release; **needs JDK ≤ 21** at `~/.local/jdk` — Android Studio now bundles 25, which crashes it |
| JSON/YAML | `vscode-json-language-server`, `yaml-language-server` | `npm i -g vscode-langservers-extracted yaml-language-server` |
| Bash | `bash-language-server` | `npm i -g bash-language-server` |
| Docker | `docker-langserver` | `npm i -g dockerfile-language-server-nodejs` |

Formatters for `conform.nvim` are external too: prettier, gofumpt, goimports, ruff,
stylua, shfmt, dart. Missing ones are skipped silently.

## Rollback

The LazyVim setup is frozen in git:

```
git checkout nvim-lazyvim-final -- nvim     # config
nvim +'Lazy restore'                        # plugin revisions from lazy-lock.json
```

A tarball of the same tree is in `~/nvim-backups/`, and the pre-rebuild plugin/tool
data (lazy, mason, treesitter parsers) is in `~/nvim-backups/old-data-*/` — move those
back into `~/.local/share/nvim/` if you want the old state back exactly.
