# Fedora 44 + Niri Workstation Plan

Status: draft, not executed  
Date: 2026-10-20  
Target machine: current Fedora 44 install, single laptop screen (`eDP-1`)

## Scope

- Keep Fedora 44. No NixOS migration in this plan.
- Make Niri the primary keyboard-driven session.
- Keep KDE Plasma installed as a fallback, including for GlobalProtect if needed.
- Keep Sway as an optional second fallback.
- Use named Niri workspaces so `Super+1..9` behaves like fixed project slots.
- Use one tmux server with one session per project.
- Use OpenCode as the primary AI CLI; run Claude on demand.

## Current environment

- Fedora Linux 44 (Workstation Edition).
- Current session: KDE Plasma 6.7.5 on Wayland.
- CPU/GPU: Intel i5-11300H, Intel Iris Xe.
- Wi-Fi: Intel Wi-Fi 6 AX201; requires `hardware.enableRedistributableFirmware` only on NixOS, already working on Fedora.
- Single connected output: `eDP-1`, 1920x1080.
- Future external output: `HDMI-A-1`.
- GlobalProtect:
  - `gpd.service` is system-level, enabled and active.
  - `PanGPS` and `PanGpHip` run as root.
  - `PanGPUI` and `PanGPA` run in the user session.
  - The `/usr/bin/globalprotect` binary is vendor-installed and not owned by an RPM.
- Fedora 44 packages:
  - `niri` 26.04-1.fc44 is available in updates.
  - `xwayland-satellite` 0.8.2 is available in updates.
- Already installed: `waybar`, `kanshi`, `swaylock`, `swayidle`, `wl-clipboard`, `fzf`, `jq`, `ghostty`, `tmux`, `neovim`.
- Needed additions: `niri`, `xwayland-satellite`, `fuzzel`, `mako`, `cliphist`.

## Workspace map

All workspaces currently live on `eDP-1`. Browser/chat/misc will move to HDMI later when an external monitor is available.

| Key | Workspace | Contents |
|---|---|---|
| `Super+1` | `esdm` | Simpel ESDM |
| `Super+2` | `fifil` | Audit Platform |
| `Super+3` | `rally` | Mari Rally |
| `Super+4` | `msafe` | MariSafe |
| `Super+5` | reserved | temporary worktree or future project |
| `Super+6` | reserved | temporary worktree or future project |
| `Super+7` | `browser` | Browser |
| `Super+8` | `chat` | Messaging |
| `Super+9` | `misc` | Files, settings, notes |

Recommendation: keep browser/chat/misc as separate named workspaces, not extra columns inside a project workspace.

## Project registry

`~/.config/projects.tsv`:

```tsv
esdm	Simpel ESDM	~/works/2026/esdm	opencode
fifil	Audit Platform	~/works/2026/fifil	opencode
rally	Mari Rally	~/works/2026/rally	opencode
msafe	MariSafe	~/works/2026/marisafe	opencode
```

Columns: workspace slug, display name, project path, primary AI CLI.

`~/development/flutter` is the Flutter SDK/toolchain, not a project workspace. Flutter application work happens inside the product monorepos (`esdm`, `rally`, `msafe`).

## Rally repository cleanup

There are currently three checkouts of the same Mari Rally remote:

- `~/works/2026/rally` — branch `develop`
- `~/works/2026/marirally_project` — branch `feature/marshall-panitia-monitor`
- `~/project/marirally_project` — branch `feature/client-decisions-implementation`

Recommendation:

- Keep `~/works/2026/rally` as the canonical clone.
- Confirm the other branches are pushed.
- Convert the other working copies to git worktrees, for example:

```text
~/works/2026/rally-worktrees/marshall
~/works/2026/rally-worktrees/client-decisions
```

- Add a temporary `rally2` entry to `projects.tsv` only when two branches are actively open.
- Do not delete the old checkouts until the worktrees and branches are verified.

## Niri configuration outline

Named workspaces, single-screen version:

```kdl
workspace "esdm"
workspace "fifil"
workspace "rally"
workspace "msafe"
workspace "browser"
workspace "chat"
workspace "misc"
```

Do not add `open-on-output` rules until an external monitor is connected.

Project launch bindings:

```kdl
Mod+1 { spawn-sh "project esdm"; }
Mod+2 { spawn-sh "project fifil"; }
Mod+3 { spawn-sh "project rally"; }
Mod+4 { spawn-sh "project msafe"; }
```

Reference workspace bindings:

```kdl
Mod+7 { focus-workspace "browser"; }
Mod+8 { focus-workspace "chat"; }
Mod+9 { focus-workspace "misc"; }
```

Other bindings:

```kdl
Mod+Shift+1 { move-column-to-workspace "esdm"; }
Mod+Shift+2 { move-column-to-workspace "fifil"; }
Mod+Shift+3 { move-column-to-workspace "rally"; }
Mod+Shift+4 { move-column-to-workspace "msafe"; }

Mod+Tab     { toggle-overview; }
Mod+Return  { spawn "ghostty"; }
Mod+D       { spawn "fuzzel"; }
Mod+P       { spawn-sh "project-pick"; }
Mod+Q       { close-window; }
Mod+Space   { toggle-window-floating; }
Mod+Shift+F { fullscreen-window; }
Mod+Shift+V { spawn-sh "globalprotect launch-ui"; }
Print       { screenshot; }
Mod+Alt+L   { spawn "swaylock"; }
Mod+Escape  { toggle-keyboard-shortcuts-inhibit; }
```

Use `repeat=false` and a short cooldown on the project binds to avoid spawning multiple launcher scripts while a key is held.

Window rules to start with:

```kdl
window-rule {
    match app-id="firefox$"
    open-on-workspace "browser"
}

window-rule {
    match app-id=r#"^org\.telegram\.desktop$"#
    open-on-workspace "chat"
}

window-rule {
    match app-id=r#"^com\.slack\.Slack$"#
    open-on-workspace "chat"
}

window-rule {
    match app-id=r#"^com\.discordapp\.Discord$"#
    open-on-workspace "chat"
}
```

Use `niri msg pick-window` to identify the real app IDs for Slack, Telegram, Discord, and GlobalProtect. Keep GlobalProtect dialogs floating.

## Kanshi profile: single screen

```text
profile {
    output eDP-1 enable
}
```

Monitor-focus and workspace-move bindings can stay in the config for future use, but they are not needed day to day:

```kdl
Mod+Ctrl+Left  { focus-monitor-left; }
Mod+Ctrl+Right { focus-monitor-right; }

Mod+Shift+Left  { move-column-to-monitor-left; }
Mod+Shift+Right { move-column-to-monitor-right; }

Mod+Ctrl+Shift+Left  { move-workspace-to-monitor-left; }
Mod+Ctrl+Shift+Right { move-workspace-to-monitor-right; }
```

## Tmux layout

One tmux server. One session per project, named after the workspace slug. One Ghostty client per project workspace.

| Window | Name | Startup |
|---|---|---|
| `1` | `shell` | automatic |
| `2` | `nvim` | automatic |
| `3` | `opencode` | automatic |
| `4` | `run` | on demand |
| `5` | `logs` | on demand |
| `6` | `git` | on demand |

Conventions:

- Keep `Ctrl-a` as the tmux prefix.
- `C-a 1/2/3` selects shell/Neovim/OpenCode.
- `C-a C` opens a temporary Claude window on demand.
- `C-a |` and `C-a -` split panes for logs/tests.
- `C-a z` zooms the current pane.
- Disable automatic window renaming so AI CLIs cannot rename windows.
- Status bar shows the project display name and current window.
- Use a grouped tmux session only when the same project must appear on two screens.
- For different projects on different screens later, use separate sessions and clients.

Project launcher behavior:

1. Focus the named workspace with `niri msg action focus-workspace "<slug>"`.
2. If the tmux session does not exist, create it with `shell`, `nvim`, and `opencode`.
3. If no terminal exists on the workspace, spawn Ghostty attached to the session.
4. If the terminal already exists, just focus the workspace.

## GlobalProtect plan

Tray is required, but it does not have to live inside Niri. KDE fallback is accepted.

Order of attempts:

1. Test Niri first: Waybar `tray` module + `xembedsniproxy` + `globalprotect launch-ui`.
2. Start `xembedsniproxy` only after the XWayland socket exists.
3. Verify the tray icon, connect/disconnect menu, UI window, VPN routes/DNS, suspend/resume, and reconnect.
4. If the tray cannot be bridged under Niri, log into KDE, connect GlobalProtect, then switch back to Niri.
5. Test whether the VPN tunnel survives the session switch. `gpd.service` is system-level, so it may persist after `PanGPUI` exits.
6. If the tunnel does not survive, use KDE whenever VPN access is required and Niri for local/offline development.

The tray requirement is considered satisfied if it works in the KDE fallback session.

## Fedora 44 execution order

1. Commit and back up dotfiles and current configs.
2. Install packages:

```bash
sudo dnf install niri xwayland-satellite fuzzel mako cliphist
```

3. Create and version these in `~/dotfiles`:
   - `niri/config.kdl`
   - `niri/scripts/project`
   - `niri/scripts/project-pick`
   - `projects.tsv`
   - `tmux/tmux.conf` additions
   - `kanshi/config`
   - `waybar/config.jsonc`
   - `waybar/style.css`
4. Test Niri nested inside KDE for keybindings and basic layout.
5. Log into a real Niri session and verify `xwayland-satellite`.
6. Test GlobalProtect in Niri; use the KDE fallback if needed.
7. Validate single-screen workflow: `Super+1..4`, `Super+7/8/9`, tmux, Neovim, OpenCode, Claude-on-demand.
8. Use daily for 1-2 weeks while keeping KDE as fallback.

## Validation checklist

- `Super+1..4` focuses each project workspace and starts the stack only when needed.
- `Super+7/8/9` focuses browser/chat/misc.
- Browser/chat windows open on the correct named workspaces.
- tmux sessions survive closing the terminal.
- OpenCode opens in the project directory.
- Claude opens on demand in a temporary tmux window.
- Neovim/LazyVim retains its existing configuration.
- GlobalProtect connects under Niri, or the KDE fallback works.
- VPN persistence across session switch is tested.
- Suspend/resume and reconnect work.
- Screen sharing is tested as a nice-to-have.

## Future HDMI expansion

When `HDMI-A-1` is connected:

1. Identify the output with `niri msg outputs` or `kscreen-doctor -o`.
2. Add a Kanshi profile for `eDP-1` + `HDMI-A-1`.
3. Add `open-on-output "HDMI-A-1"` to `browser`, `chat`, and `misc`.
4. Test hotplug, fallback when HDMI is disconnected, and return when reconnected.
5. Keep project workspaces pinned to `eDP-1`.

Suggested future workspace rules:

```kdl
workspace "browser" { open-on-output "HDMI-A-1"; }
workspace "chat"    { open-on-output "HDMI-A-1"; }
workspace "misc"    { open-on-output "HDMI-A-1"; }
```

## Deferred

- NixOS migration.
- Flutter-on-NixOS toolchain work.
- Any automatic session restore across reboots.
- Multi-monitor configuration beyond the future HDMI expansion above.

## Open items

- Confirm the external monitor's position and resolution when HDMI is available.
- Confirm browser and messaging app IDs with `niri msg pick-window`.
- Confirm whether the VPN tunnel persists across a KDE-to-Niri session switch.
- Confirm the exact `run` command per project for the optional tmux window.
