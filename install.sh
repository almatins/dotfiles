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
link "i3/.config/i3/config" ".config/i3/config"
link "i3/.config/i3/lock.sh" ".config/i3/lock.sh"
link "i3/.local/bin/power-menu.sh" ".local/bin/power-menu.sh"
link "i3status/.config/i3status/config" ".config/i3status/config"
link "rofi/.config/rofi/config.rasi" ".config/rofi/config.rasi"
link "dunst/.config/dunst/dunstrc" ".config/dunst/dunstrc"
link "gtk/.config/gtk-3.0/settings.ini" ".config/gtk-3.0/settings.ini"
link "gtk/.config/gtk-4.0/settings.ini" ".config/gtk-4.0/settings.ini"
link "gtk/.gtkrc-2.0"       ".gtkrc-2.0"
link "xsettingsd/.config/xsettingsd/xsettingsd.conf" ".config/xsettingsd/xsettingsd.conf"

echo
echo "Done."
echo "  Reload tmux with:   tmux source-file ~/.tmux.conf"
echo "  Reload bash with:   exec bash"
echo "  Reload i3 with:     i3-msg restart"
