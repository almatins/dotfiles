#!/usr/bin/env bash
# Power menu for i3 — bound to Mod4+Shift+Escape (see ~/.config/i3/config).
#
# rofi in dmenu mode, inheriting ~/.config/rofi/theme.rasi.
# Destructive entries (logout, reboot, poweroff) ask for confirmation first, since
# Mod4+Shift+Escape sits right next to Mod4+Escape (lock) on the keyboard.
set -uo pipefail

LOCK="  Kunci layar"
LOCK_OFF="  Kunci + matikan layar"
SLEEP="  Tidur"
LOGOUT="  Keluar sesi"
REBOOT="  Nyalakan ulang"
POWEROFF="  Matikan"

menu() {  # $1 = prompt, $2 = window height in px (confirmation needs less)
    local prompt=$1 height=${2:-380}
    rofi -dmenu -i -p "$prompt" -no-custom \
        -theme-str "window { width: 480px; height: ${height}px; } prompt { enabled: true; } entry { placeholder: \"\"; }"
}

confirm() {  # $1 = question; "Tidak" is preselected, so Enter alone is safe
    local answer
    answer=$(printf 'Tidak\nYa\n' | menu "$1" 190) || return 1
    [ "$answer" = "Ya" ]
}

choice=$(printf '%s\n' "$LOCK" "$LOCK_OFF" "$SLEEP" "$LOGOUT" "$REBOOT" "$POWEROFF" \
    | menu "Menu daya") || exit 0
[ -z "${choice:-}" ] && exit 0

case "$choice" in
    "$LOCK")
        exec "$HOME/.config/i3/lock.sh"
        ;;
    "$LOCK_OFF")
        # Lock in the background, power the panel down, then stay until unlock.
        "$HOME/.config/i3/lock.sh" &
        sleep 0.5
        xset dpms force off
        wait
        ;;
    "$SLEEP")
        systemctl suspend
        ;;
    "$LOGOUT")
        confirm "Keluar dari sesi ini?" && i3-msg exit
        ;;
    "$REBOOT")
        confirm "Nyalakan ulang komputer?" && systemctl reboot
        ;;
    "$POWEROFF")
        confirm "Matikan komputer?" && systemctl poweroff
        ;;
esac
