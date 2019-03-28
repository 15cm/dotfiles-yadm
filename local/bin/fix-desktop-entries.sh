#/bin/bash
app_folder="/usr/share/applications"

# plex
sudo rm -f $app_folder/plexmediaplayer.desktop
sudo sed -i 's/Exec=\S*$/& --desktop --scale-factor=2/' $app_folder/plex-media-player.desktop
