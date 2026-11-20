#!/bin/sh
# Fixed i3 workspace buttons for polybar, including workspaces that do not
# exist yet (i3 destroys empty ones, so internal/i3 hides them).
#
# Keep this list in sync with the `set $wsN` variables in ~/.config/i3/config.
ALL='["0:misc","1:oc","2:nvim","3:web","4:term","5:mob","6:mar","7:mar2","8:p3","9:p4"]'

JQ='
  . as $live
  | [ range(0; ($all | length)) as $i
      | $all[$i] as $name
      | ([ $live[] | select(.name == $name) ][0]) as $w
      | (if $w == null then "unfocused"
         elif $w.focused then "focused"
         elif $w.urgent then "urgent"
         elif $w.visible then "visible"
         else "unfocused" end) as $state
      | (if $state == "focused" then "%{B#cba6f7}%{F#1e1e2e}"
         elif $state == "urgent" then "%{B#f38ba8}%{F#1e1e2e}"
         elif $state == "visible" then "%{F#a6adc8}"
         else "%{F#7f849c}" end) as $pre
      | (if $state == "focused" or $state == "urgent" then "%{B-}%{F-}" else "%{F-}" end) as $post
      | "%{A1:/home/almatins/.config/polybar/scripts/ws-switch.sh \($i):}" + $pre + " \($name) " + $post + "%{A}"
    ]
  | join("")
  | if $mode != "default" then . + " %{B#cba6f7}%{F#1e1e2e} \($mode) %{B-}%{F-}" else . end
'

render() {
    mode=$(i3-msg -t get_binding_state 2>/dev/null | jq -r '.name // "default"')
    i3-msg -t get_workspaces 2>/dev/null |
        jq --unbuffered -c -r --argjson all "$ALL" --arg mode "$mode" "$JQ"
}

# First render straight away, then on every workspace/output/mode change.
render
i3-msg -t subscribe -m '["workspace", "output", "mode"]' |
    while read -r _; do render; done
