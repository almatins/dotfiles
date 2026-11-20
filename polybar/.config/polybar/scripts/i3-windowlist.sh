#!/bin/sh
# Compact window list for polybar: every window on the focused workspace,
# the focused one highlighted, click to focus. Replaces i3's mandatory
# stacking/tabbed title strip, which cannot be hidden.
#
# Note: i3's tree does not mark the focused workspace, so the name comes from
# GET_WORKSPACES. Click actions use con_id (a plain integer), so nothing in the
# command string collides with polybar's %{A1:command:} colon parsing.

render() {
    ws=$(i3-msg -t get_workspaces 2>/dev/null | jq -r '.[] | select(.focused) | .name' | head -n1)
    [ -n "$ws" ] || return 0

    i3-msg -t get_tree 2>/dev/null | jq --unbuffered -r -c --arg ws "$ws" '
        ([ .. | objects | select(.type == "workspace" and .name == $ws) ][0]) as $w
        | [ $w | .. | objects | select(.window)
            | {id: .id, title: (.name // ""), focused: (.focused // false)} ]
        | map(
            (.title | gsub("\\s+"; " ") | .[0:30]) as $t
            | (if .focused then "%{B#cba6f7}%{F#1e1e2e}" else "%{F#a6adc8}" end) as $pre
            | (if .focused then "%{B-}%{F-}" else "%{F-}" end) as $post
            | "%{A1:i3-msg -q [con_id=\(.id)] focus:}" + $pre + " \($t) " + $post + "%{A}"
          )
        | join("  ")
    '
}

render
i3-msg -t subscribe -m '["window", "workspace"]' |
    while read -r _; do render; done
