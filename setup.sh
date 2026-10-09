mv -i extensions ~/.local/share/gnome-shell
dconf load /org/gnome/shell/extensions/ < extensions.dconf
sudo dnf install python3
python3 dtp-monitors.py
