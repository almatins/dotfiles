#!/usr/bin/env bash
# Power menu for i3 — bound to Mod4+Shift+Escape (see ~/.config/i3/config).
#
# rofi in dmenu mode, inheriting ~/.config/rofi/theme.rasi.
# Destructive entries (logout, reboot, poweroff) ask for confirmation first, since
# Mod4+Shift+Escape sits right next to Mod4+Escape (lock) on the keyboard.
set -uo pipefail

LOCK="  Lock screen"
LOCK_OFF="  Lock + screen off"
SLEEP="  Sleep"
LOGOUT="  Log out"
REBOOT="  Reboot"
POWEROFF="  Power off"

menu() {  # $1 = prompt, $2 = window height in px (confirmation needs less)
    local prompt=$1 height=${2:-380}
    rofi -dmenu -i -p "$prompt" -no-custom -no-show-icons \
        -theme-str "window { width: 480px; height: ${height}px; } prompt { enabled: true; } entry { placeholder: \"\"; }"
}

confirm() {  # $1 = question; "No" is preselected, so Enter alone is safe
    local answer
    answer=$(printf 'No\nYes\n' | menu "$1" 190) || return 1
    [ "$answer" = "Yes" ]
}

choice=$(printf '%s\n' "$LOCK" "$LOCK_OFF" "$SLEEP" "$LOGOUT" "$REBOOT" "$POWEROFF" \
    | menu "Power menu") || exit 0
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
        confirm "Log out of this session?" && i3-msg exit
        ;;
    "$REBOOT")
        confirm "Reboot the computer?" && systemctl reboot
        ;;
    "$POWEROFF")
        confirm "Power off the computer?" && systemctl poweroff
        ;;
esac
