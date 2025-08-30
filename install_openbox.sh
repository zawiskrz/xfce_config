#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska Openbox..." | tee -a "$LOGFILE"
sudo apt install -y \
openssh-server  ufw \
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


echo "🗂️ Nadpisywanie konfiguracji użytkownika..." | tee -a "$LOGFILE"

# Openbox
mkdir -p ~/.config/openbox
cp -f config/openbox/* ~/.config/openbox/

# Tint2
mkdir -p ~/.config/tint2
cp -f config/tint2/* ~/.config/tint2/

# JGMenu
mkdir -p ~/.config/jgmenu
cp -f config/jgmenu/* ~/.config/jgmenu/

# GTK 3.0
mkdir -p ~/.config/gtk-3.0
cp -f config/gtk-3.0/* ~/.config/gtk-3.0/

# Rhythmbox (lokalne dane)
mkdir -p ~/.local/share/rhythmbox
cp -f local/rhythmbox/* ~/.local/share/rhythmbox/

echo "🖼️ Kopiowanie tapet..." | tee -a "$LOGFILE"
mkdir -p ~/tapety
cp -f tapety/* ~/tapety/

echo "🖼️ Ustawianie tapety pulpitu..." | tee -a "$LOGFILE"
nitrogen --set-scaled ~/tapety/planety.jpg --save

# Resetowanie ustawień zapory
sudo ufw --force reset 2>&1 | tee -a "$LOGFILE"

# Domyślne polityki
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Dodanie reguł dostępu
sudo ufw allow from 192.168.0.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 139 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 139 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 445 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 445 proto tcp
sudo ufw allow from 192.168.0.0/24 to any port 1716
sudo ufw allow from 192.168.1.0/24 to any port 1716

# Włączenie zapory
sudo ufw --force enable 2>&1 | tee -a "$LOGFILE"

echo "✅ Zapora UFW została skonfigurowana i aktywowana." | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm 2>&1 | tee -a "$LOGFILE"


echo "✅ Instalacja zakończona. Środowisko Openbox zostało skonfigurowane." 
