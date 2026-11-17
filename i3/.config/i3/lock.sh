#!/bin/sh
# Screen locker used by xss-lock (before suspend) and Mod4+Escape.
#
# i3lock-color (COPR lxdes/i3lock-color) shows a real indicator, a greeter
# prompt, "Checking…" while PAM runs, "Wrong password" plus a failed-attempt
# counter otherwise. Stock i3lock 2.16 draws none of that, so fall back to a
# minimal flag set it understands.
#
# Both lockers must stay in the foreground (no fork): xss-lock waits for the
# process to exit before it releases its logind suspend lock.

if i3lock --version 2>&1 | grep -qE '2\.13\.c|i3lock-color'; then
    exec i3lock \
        --color=1e1e2e \
        --inside-color=00000000 \
        --ring-color=666666ff \
        --line-color=00000000 \
        --keyhl-color=83cafaff \
        --bshl-color=ec69a0ff \
        --separator-color=00000000 \
        --insidever-color=3c6eb4ff \
        --ringver-color=83cafaff \
        --insidewrong-color=db3279ff \
        --ringwrong-color=ec69a0ff \
        --verif-color=ffffffff \
        --wrong-color=ec69a0ff \
        --greeter-color=ccccccff \
        --verif-text="Checking…" \
        --wrong-text="Wrong password" \
        --greeter-text="Type password" \
        --verif-font="JetBrainsMono Nerd Font" \
        --wrong-font="JetBrainsMono Nerd Font" \
        --greeter-font="JetBrainsMono Nerd Font" \
        --verif-size=16 \
        --wrong-size=16 \
        --greeter-size=16 \
        --greeter-pos="x+w/2:y+h/2+r+30" \
        --show-failed-attempts \
        --indicator \
        --nofork "$@"
fi

exec i3lock -n "$@"
