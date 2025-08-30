#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska Openbox..." | tee -a "$LOGFILE"

sudo apt install -y \
openssh-server  \
xorg lightdm lightdm-gtk-greeter \
openbox obconf lxappearance xdg-utils python3-xdg \
nitrogen \
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
x11-xserver-utils \
pulseaudio pulseaudio-utils pulseaudio-module-bluetooth pavucontrol libcanberra-pulse pasystray \
bluez blueman xfce4-power-manager \
firefox-esr thunderbird vlc calibre rhythmbox shotwell libreoffice libreoffice-l10n-pl libreoffice-help-pl \
wxmaxima \
python3 python3-pip python3-venv \
mc htop 2>&1 | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm 2>&1 | tee -a "$LOGFILE"

echo "🗂️ Tworzenie pliku autostartu Openbox..." | tee -a "$LOGFILE"
mkdir -p ~/.config/openbox 2>> "$LOGFILE"

cat <<EOF > ~/.config/openbox/autostart
# Automatyczne uruchamianie komponentów pulpitu

# Ustawienie tapety
# feh --bg-scale /ścieżka/do/tapety.jpg &

# Ustawienie rozdzielczości HD 
xrandr --output Virtual-1  --mode 1920x1080 --rate 60 &

# Panel
tint2 &

# Aplet sieci
nm-applet &

# Menedżer Bluetooth
blueman-applet &

# Terminal
#xfce4-terminal &

# Kompozytor okien
compton &

# Monitor systemu
#conky &

#Manadzer zasilania
xfce4-power-manager &
EOF

echo "✅ Plik autostartu utworzony w ~/.config/openbox/autostart" | tee -a "$LOGFILE"
