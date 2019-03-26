#/bin/bash
app_folder="/usr/share/applications"

# plex
sudo rm -f $app_folder/plexmediaplayer.desktop

# bluez-git
sudo sed -i 's/\(ExecStart=\).*/\1\/usr\/lib\/bluetoothd/' /usr/lib/systemd/system/bluetooth.service
