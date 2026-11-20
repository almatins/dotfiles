#!/bin/sh
# Click handler for the polybar i3 workspace module.
# Called with the workspace INDEX (0..9) so the polybar action string contains
# no colon (the name itself is "N:label", which would break %{A1:cmd:}).
#
# Keep this list in sync with scripts/i3-workspaces.sh and the `set $wsN`
# variables in ~/.config/i3/config.
case "${1:-}" in
    0) ws="0:misc" ;;
    1) ws="1:oc" ;;
    2) ws="2:nvim" ;;
    3) ws="3:web" ;;
    4) ws="4:term" ;;
    5) ws="5:mob" ;;
    6) ws="6:mar" ;;
    7) ws="7:mar2" ;;
    8) ws="8:p3" ;;
    9) ws="9:p4" ;;
    *) exit 1 ;;
esac

exec i3-msg -q "workspace $ws"
