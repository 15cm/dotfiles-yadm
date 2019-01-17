#!/bin/bash

systemctl --user restart xsession.target

# External keyboard
if lsusb | grep -q -E 'feed.*(1307|6060)'; then
  systemctl --user stop laptop-keymap.service
else
  systemctl --user restart laptop-keymap.service
fi

# External Display(2 screens)
monitor_num=$(xrandr -q | grep ' connected' | wc -l)
if [ $monitor_num != 1 ]; then
  # Assign workspaces to screens
  ~/local/bin/move-workspaces.sh
fi

