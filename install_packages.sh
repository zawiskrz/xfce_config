#!/bin/bash

# Skrypt instalacyjny środowiska Openbox + dodatki

echo "🔧 Aktualizacja listy pakietów..."
sudo apt update

echo "📦 Instalacja pakietów..."
sudo apt install -y \
mc htop \
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
thunar xfce4-terminal network-manager-gnome feh jgmenu menu

echo "🔄 Restart LightDM..."
sudo systemctl restart lightdm

echo "🚀 Uruchamianie komponentów Openbox..."
#feh --bg-scale /ścieżka/do/tapety.jpg &
tint2 &
nm-applet &
xfce4-terminal &
