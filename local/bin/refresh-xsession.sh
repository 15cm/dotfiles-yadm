#!/bin/bash

systemctl --user restart xsession.target
kcminit kcm_touchpad

# Tell current mode by connection of external keyboard

# Desktop mode
if lsusb | grep -q -E 'feed.*(1307|6060)'; then
  systemctl --user stop laptop-keymap.service
  ~/local/bin/move-workspaces.sh
# Laptop mode
else
  systemctl --user restart laptop-keymap.service
fi
