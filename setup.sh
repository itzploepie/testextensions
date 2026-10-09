sudo dnf remove gnome-weather gnome-tour gnome-font-viewer gnome-contacts gnome-connections gnome-clocks gnome-characters gnome-calendar gnome-calculator gnome-boxes libreoffice-core
sudo dnf install python3
sudo dnf update
sudo dnf autoremove
mv -i extensions ~/.local/share/gnome-shell
dconf load /org/gnome/shell/extensions/ < extensions.dconf
python3 dtp-monitors.py
gnome-extensions enable Vitals@CoreCoding.com
gnome-extensions enable arcmenu@arcmenu.com
gnome-extensions enable dash-to-panel@jderose9.github.com
gnome-extensions enable ding@rastersoft.com
gnome-extensions enable user-accent-colors@fabito02
