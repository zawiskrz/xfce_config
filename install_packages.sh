#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska Openbox..." | tee -a "$LOGFILE"
sudo apt install -y \
openssh-server  \
xorg lightdm lightdm-gtk-greeter \
openbox obconf lxappearance xdg-utils python3-xdg \
nitrogen jgmenu menu rofi \
upower dmz-cursor-theme \
compton \
tint2 papirus-icon-theme \
network-manager-gnome \
pulseaudio pulseaudio-utils pulseaudio-module-bluetooth pavucontrol libcanberra-pulse pasystray \
bluez blueman xfce4-power-manager xfce4-appfinder \
thunar thunar-volman gvfs udisks2 xfce4-terminal \
firefox-esr thunderbird vlc calibre rhythmbox shotwell \
libreoffice libreoffice-l10n-pl libreoffice-help-pl \
wxmaxima \
python3 python3-pip python3-venv \
mc htop \
x11-xserver-utils 2>&1 | tee -a "$LOGFILE"


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

echo "🖼️ Kopiowanie katalogu 'tapety' i ustawianie tapety pulpitu..." | tee -a "$LOGFILE"

# 📁 Kopiowanie katalogu 'tapety' do katalogu domowego
cp -R ./tapety "$HOME" 2>> "$LOGFILE"

# 🖼️ Ustawienie tapety 'planety.jpg' jako tła pulpitu
nitrogen --set-scaled "$HOME/tapety/planety.jpg" --save 2>> "$LOGFILE"
echo "✅ Tapeta 'planety.jpg' ustawiona jako tło pulpitu (tryb: scaled)" | tee -a "$LOGFILE"

