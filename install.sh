#!/usr/bin/env bash
# Symlink the configs in this repo into their real locations.
# Idempotent: safe to re-run. Any pre-existing real file is moved aside, never deleted.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$DOTFILES/$1" dest="$HOME/$2"

  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    echo "ok       $dest"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.backup-$STAMP"
    echo "moved    $dest -> $dest.backup-$STAMP"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "linked   $dest -> $src"
}

link "bash/.bashrc"         ".bashrc"
link "tmux/.tmux.conf"      ".tmux.conf"
link "nvim/.config/nvim"    ".config/nvim"
link "alacritty/.config/alacritty/alacritty.toml" ".config/alacritty/alacritty.toml"

echo
echo "Done."
echo "  Reload tmux with:   tmux source-file ~/.tmux.conf"
echo "  Reload bash with:   exec bash"
