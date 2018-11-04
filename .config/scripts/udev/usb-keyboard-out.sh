#!/bin/sh
sleep 2
lsusb | grep -q -E 'feed.*(1307|6060)' ||
su sinkerine -c "DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user start laptop-keymap.service"
