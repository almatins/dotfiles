# dotfiles

Config files for tmux and Neovim, tracked in git and symlinked into place.

## Layout

Directories are [GNU stow](https://www.gnu.org/software/stow/)-compatible, so if you
ever `dnf install stow` you can use `stow tmux nvim` instead of `install.sh` with no
changes to this repo.

```
tmux/.tmux.conf          ->  ~/.tmux.conf
nvim/.config/nvim/       ->  ~/.config/nvim
```

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

- Fedora, Wayland, Ptyxis terminal
- tmux 3.7b, Neovim 0.12.4
- Caps Lock and Ctrl swapped at the X11/Wayland layer (`ctrl:swapcaps`)
- Claude Code runs inside tmux, which is why `allow-passthrough` and `extended-keys`
  are set in `tmux.conf` — see the comments in that file.
