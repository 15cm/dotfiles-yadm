#!/bin/sh
lsusb | grep -q 'feed.*1307'||
su sinkerine -c "DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user start laptop-keymap.service"
