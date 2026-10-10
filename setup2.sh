#!/bin/bash

while true; do

read -p "This script will replace your extensions folder with a new one. Do you want to proceed? (y/n) " yn

case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done

echo starting script

gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
mv -f extensions ~/.local/share/gnome-shell
dconf load /org/gnome/shell/extensions/ < extensions.dconf
python3 dtp-monitors.py
gsettings set org.gnome.shell enabled-extensions "['Vitals@CoreCoding.com', 'arcmenu@arcmenu.com', 'dash-to-panel@jderose9.github.com', 'ding@rastersoft.com', 'user-accent-colors@fabito02']"
echo Done, log out and back in to enable the extensions.
