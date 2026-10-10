#!/bin/bash

while true; do

read -p "This script is going to remove packages and will replace your extensions folder with a new one. Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

echo starting script

sudo dnf remove gnome-weather gnome-tour gnome-font-viewer gnome-contacts gnome-connections gnome-clocks gnome-characters gnome-calendar gnome-calculator gnome-boxes libreoffice-core
sudo dnf install python3 fastfetch gnome-tweaks
sudo dnf autoremove
sudo dnf update
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
mv -f extensions ~/.local/share/gnome-shell
dconf load /org/gnome/shell/extensions/ < extensions.dconf
python3 dtp-monitors.py
gnome-extensions enable Vitals@CoreCoding.com
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable ding@rastersoft.com
gnome-extensions enable user-accent-colors@fabito02
echo Done, log out and back in to enable the extensions.
