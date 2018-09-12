#!/bin/sh
echo 'auto' > /sys/bus/usb/devices/2-3/power/control
if lsusb | grep -q -E 'feed.*(1307|6060)'; then
  su sinkerine -c "DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user stop laptop-keymap.service"
else
  sleep 2
  kcm_init kcm_touchpad
  su sinkerine -c "DISPLAY=:0 XDG_RUNTIME_DIR=/run/user/1000 systemctl --user restart laptop-keymap.service"
fi
