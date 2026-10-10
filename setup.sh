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

sudo dnf remove gnome-weather gnome-tour gnome-font-viewer gnome-contacts gnome-connections gnome-clocks gnome-characters gnome-calendar gnome-calculator gnome-boxes gnome-maps gnome-help gnome-system-monitor libreoffice-core mediawriter simple-scan malcontent-control
sudo dnf copr enable atim/resources
sudo dnf install python3 fastfetch gnome-tweaks gnome-extensions-app resources
sudo dnf autoremove
sudo dnf update
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
mv -f extensions ~/.local/share/gnome-shell
dconf load /org/gnome/shell/extensions/ < extensions.dconf
python3 dtp-monitors.py
gsettings set org.gnome.shell enabled-extensions "['Vitals@CoreCoding.com', 'arcmenu@arcmenu.com', 'dash-to-panel@jderose9.github.com', 'ding@rastersoft.com', 'user-accent-colors@fabito02']"
echo Done, log out and back in to enable the extensions.
