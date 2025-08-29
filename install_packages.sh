#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska Openbox..." | tee -a "$LOGFILE"
sudo apt install -y \
xorg lightdm lightdm-gtk-greeter \
openbox obconf lxappearance xdg-utils python3-xdg \
upower dmz-cursor-theme \
compton conky-all \
rxvt-unicode tmux pkexec \
tint2 spacefm udevil \
geany geany-plugin-spellcheck \
qt5ct \
gtk2-engines gtk2-engines-murrine gtk2-engines-pixbuf murrine-themes libgtk2.0-bin \
gnome-icon-theme gnome-icon-theme-symbolic gnome-themes-extra at-spi2-core \
mate-themes papirus-icon-theme \
dconf-editor dconf-cli \
thunar xfce4-terminal network-manager-gnome feh jgmenu menu \
mc htop 2>&1 | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm 2>&1 | tee -a "$LOGFILE"

echo "🚀 Uruchamianie komponentów Openbox..." | tee -a "$LOGFILE"
feh --bg-scale /ścieżka/do/tapety.jpg &>> "$LOGFILE"
tint2 &>> "$LOGFILE"
nm-applet &>> "$LOGFILE"
xfce4-terminal &>> "$LOGFILE"
