#!/bin/sh
# Fixed workspace buttons for i3bar (i3 >= 4.23, bar { workspace_command }).
#
# i3 destroys empty workspaces, so the default buttons disappear until a
# workspace has a window. This feeds i3bar a fixed list instead: every
# workspace below is always drawn, in this order, and clicking one switches to
# it (i3 creates it on demand).
#
# Keep this list in sync with the `set $wsN` variables in ~/.config/i3/config.
WORKSPACES='["0:misc","1:oc","2:nvim","3:web","4:term","5:mob","6:mar","7:mar2","8:p3","9:p4"]'

i3-msg -t subscribe -m '["workspace", "output"]' | {
    # Print the current state immediately so the bar is not empty on startup.
    i3-msg -t get_workspaces
    while read -r _; do i3-msg -t get_workspaces; done
} | jq --unbuffered -c --argjson all "$WORKSPACES" '
    . as $live
    | [ $all[] as $name
        | (($live[] | select(.name == $name))
           // {name: $name, focused: false, visible: false, urgent: false})
      ]
    # keep any workspace that exists but is not in the list (e.g. ad-hoc ones)
    + [ $live[] | select(.name as $n | ($all | index($n)) | not) ]
'
