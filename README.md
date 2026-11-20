# dotfiles

Config files for tmux, Neovim, Alacritty and the i3 desktop stack (i3, i3status,
rofi, dunst, GTK/xsettingsd fonts), tracked in git and symlinked into place.

## Layout

Directories are [GNU stow](https://www.gnu.org/software/stow/)-compatible, so if you
ever `dnf install stow` you can use `stow tmux nvim alacritty i3 i3status rofi dunst gtk xsettingsd`
instead of `install.sh` with no changes to this repo.

```
bash/.bashrc                             ->  ~/.bashrc
tmux/.tmux.conf                          ->  ~/.tmux.conf
tmux/.local/bin/tmux-git                 ->  ~/.local/bin/tmux-git
nvim/.config/nvim/                       ->  ~/.config/nvim
alacritty/.config/alacritty/alacritty.toml  ->  ~/.config/alacritty/alacritty.toml
i3/.config/i3/config                     ->  ~/.config/i3/config
i3/.config/i3/lock.sh                    ->  ~/.config/i3/lock.sh
i3/.config/i3/bar-workspaces.sh          ->  ~/.config/i3/bar-workspaces.sh
polybar/.config/polybar/                 ->  ~/.config/polybar
picom/.config/picom/picom.conf           ->  ~/.config/picom/picom.conf
i3/.local/bin/power-menu.sh              ->  ~/.local/bin/power-menu.sh
i3/.local/bin/ai                         ->  ~/.local/bin/ai
i3/.local/bin/tmux-ws                    ->  ~/.local/bin/tmux-ws
i3/.local/bin/proj                       ->  ~/.local/bin/proj
i3/.local/bin/proj-ws                    ->  ~/.local/bin/proj-ws
tmux/.config/tmux/projects/              ->  ~/.config/tmux/projects
ghostty/.config/ghostty/config           ->  ~/.config/ghostty/config
i3status/.config/i3status/config         ->  ~/.config/i3status/config
rofi/.config/rofi/config.rasi            ->  ~/.config/rofi/config.rasi
rofi/.config/rofi/theme.rasi             ->  ~/.config/rofi/theme.rasi
dunst/.config/dunst/dunstrc              ->  ~/.config/dunst/dunstrc
gtk/.config/gtk-3.0/settings.ini         ->  ~/.config/gtk-3.0/settings.ini
gtk/.config/gtk-4.0/settings.ini         ->  ~/.config/gtk-4.0/settings.ini
gtk/.gtkrc-2.0                           ->  ~/.gtkrc-2.0
xsettingsd/.config/xsettingsd/xsettingsd.conf  ->  ~/.config/xsettingsd/xsettingsd.conf
systemd/.config/systemd/user/gpa.service.d/override.conf  ->  ~/.config/systemd/user/gpa.service.d/override.conf
```

Only individual files are linked (never whole `~/.config/*` directories), so backups,
per-app state and anything else you drop in those directories stay out of the repo.
The desktop files all use `JetBrainsMono Nerd Font`; bar/title fonts only apply after
`i3-msg restart` (a plain reload does not respawn `i3bar`).

`~/.bash_profile` is not tracked: it is unmodified Fedora boilerplate whose only job
is to source `~/.bashrc`, which *is* tracked.

No credentials belong in this repo. `.bashrc` was scanned before it was committed and
`~/.bashrc.d/` does not exist, so nothing else is sourced into the shell. Re-check
before adding any new file here, especially if this repo ever gains a remote.

## Install

```sh
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` is idempotent. If a real file already exists at a destination it is moved
to `<dest>.backup-<timestamp>` rather than deleted.

## Editing

The paths above are symlinks into this repo, so editing `~/.tmux.conf` *is* editing
`tmux/.tmux.conf`. There is no copy step and nothing to keep in sync — just commit.

## Restoring a previous version

```sh
cd ~/dotfiles
git log --oneline -- tmux/.tmux.conf     # find the commit you want
git checkout <commit> -- tmux/.tmux.conf # restore that version in place
tmux source-file ~/.tmux.conf            # reload
```

Commit `f8ca34a` is the pristine pre-rework snapshot: `~/.tmux.conf` exactly as it
stood before the semantic keymap redesign, and the point to fall back to if the new
keymaps don't work out.

## Environment this was built for

- Fedora, Wayland, Alacritty 0.17 (`TERM=alacritty`)
- tmux 3.8, Neovim 0.12.6
- Caps Lock and Ctrl swapped at the X11/Wayland layer (`ctrl:swapcaps`)
- Claude Code runs inside tmux, which is why `allow-passthrough` and `extended-keys`
  are set in `tmux.conf` — see the comments in that file.
