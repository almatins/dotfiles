#!/bin/sh
# Start Polybar exactly once, even when i3 re-runs exec_always on reload.
# Prefers the system package (/usr/bin/polybar).
BIN=/usr/bin/polybar
[ -x "$BIN" ] || BIN="$HOME/.local/bin/polybar"

pkill -x polybar 2>/dev/null
while pgrep -u "$UID" -x polybar >/dev/null 2>&1; do sleep 0.1; done
exec "$BIN" -c "$HOME/.config/polybar/config.ini" main
