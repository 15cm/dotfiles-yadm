#/bin/bash
app_folder="/usr/share/applications"

# bluz-git
sudo sed -i 's|\(ExecStart=\).*|\1/usr/lib/bluetoothd|' /usr/lib/systemd/system/bluetooth.service

# plex
sudo rm -f $app_folder/plexmediaplayer.desktop
sudo sed -i 's/Exec=\S*$/& --desktop --scale-factor=2/' $app_folder/plex-media-player.desktop

sudo systemctl daemon-reload
