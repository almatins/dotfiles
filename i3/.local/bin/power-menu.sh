#!/usr/bin/env bash
# Menu daya i3 — dipanggil dari pintasan Mod1+Shift+Escape.
# Dibuat 2026-11-16.
set -uo pipefail

pilihan=$(printf '%s\n' \
  "Kunci layar" \
  "Tidur" \
  "Keluar sesi" \
  "Nyalakan ulang" \
  "Matikan" \
  | rofi -dmenu -i -p "Menu daya" -lines 5 -width 32 -no-custom -theme Arc-Dark -theme-str 'window { width: 460px; height: 320px; } * { font: "JetBrainsMono Nerd Font 11"; }') || exit 0

[ -z "${pilihan:-}" ] && exit 0

case "$pilihan" in
  "Kunci layar")    "$HOME/.config/i3/lock.sh" ;;
  "Tidur")          systemctl suspend ;;
  "Keluar sesi")    i3-msg exit ;;
  "Nyalakan ulang") systemctl reboot ;;
  "Matikan")        systemctl poweroff ;;
esac
