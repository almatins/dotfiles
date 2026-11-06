# dotfiles

Config files for tmux, Neovim and Alacritty, tracked in git and symlinked into place.

## Layout

Directories are [GNU stow](https://www.gnu.org/software/stow/)-compatible, so if you
ever `dnf install stow` you can use `stow tmux nvim alacritty` instead of `install.sh`
with no changes to this repo.

```
bash/.bashrc                             ->  ~/.bashrc
tmux/.tmux.conf                          ->  ~/.tmux.conf
nvim/.config/nvim/                       ->  ~/.config/nvim
alacritty/.config/alacritty/alacritty.toml  ->  ~/.config/alacritty/alacritty.toml
```

Only `alacritty.toml` is linked, not the whole `~/.config/alacritty/` directory, so
anything else Alacritty or you put there stays out of the repo.

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

- Fedora, Wayland, Ptyxis terminal
- tmux 3.7b, Neovim 0.12.4
- Caps Lock and Ctrl swapped at the X11/Wayland layer (`ctrl:swapcaps`)
- Claude Code runs inside tmux, which is why `allow-passthrough` and `extended-keys`
  are set in `tmux.conf` — see the comments in that file.
