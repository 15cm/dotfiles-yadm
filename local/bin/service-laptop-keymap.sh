#!/bin/bash
setxkbmap -I"$HOME/.xkb" -keycodes "evdev+aliases(qwerty)+local" local -print | xkbcomp -w 0 -I"$HOME/.xkb" - $DISPLAY
xmodmap $HOME/.xmodmaprc

flock -n /tmp/my.autostart.xcape.lockfile xcape -e "Control_R=Escape"
