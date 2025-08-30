#!/bin/bash

LOGFILE="install_log.txt"
PYCHARM_VERSION="2025.1"
PYCHARM_DIR="/opt/pycharm"
RSTUDIO_URL="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.04.1-748-amd64.deb"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska graficznego XFCE..." | tee -a "$LOGFILE"
sudo apt install -y \
task-xfce-desktop \
openssh-server ufw \
network-manager-gnome bluez blueman \
pulseaudio pulseaudio-utils pulseaudio-module-bluetooth pavucontrol libcanberra-pulse \
firefox-esr thunderbird vlc calibre rhythmbox shotwell \
libreoffice libreoffice-l10n-pl libreoffice-help-pl \
wxmaxima python3 python3-pip python3-venv \
playonlinux r-base r-base-dev r-recommended \
mc htop x11-xserver-utils papirus-icon-theme wget curl gdebi-core 2>&1 | tee -a "$LOGFILE"

echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
install -d ~/.config/gtk-3.0 ~/.local/share/rhythmbox ~/tapety
cp -f config/gtk-3.0/* ~/.config/gtk-3.0/
cp -f local/rhythmbox/* ~/.local/share/rhythmbox/
cp -f tapety/* ~/tapety/

echo "🖼️ Ustawianie tapety pulpitu (XFCE)..." | tee -a "$LOGFILE"
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s ~/tapety/planety.jpg
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 3

echo "🛡️ Konfiguracja zapory UFW..." | tee -a "$LOGFILE"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

for subnet in 192.168.0.0/24 192.168.1.0/24; do
  for port in 22 139 445 1716; do
    sudo ufw allow from $subnet to any port $port proto tcp
  done
done

sudo ufw --force enable
echo "✅ Zapora UFW aktywna." | tee -a "$LOGFILE"

echo "🐍 Instalacja PyCharma Community ${PYCHARM_VERSION}..." | tee -a "$LOGFILE"
wget https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz -O pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
tar -xzf pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
sudo mv pycharm-community-${PYCHARM_VERSION} "$PYCHARM_DIR"

echo "🖥️ Tworzenie skrótu do PyCharma..." | tee -a "$LOGFILE"
cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Name=PyCharm Community
Exec=${PYCHARM_DIR}/bin/pycharm.sh
Icon=${PYCHARM_DIR}/bin/pycharm.png
Type=Application
Categories=Development;IDE;
EOF


echo "🧪 Instalacja RStudio..." | tee -a "$LOGFILE"
wget "$RSTUDIO_URL" -O rstudio.deb 2>&1 | tee -a "$LOGFILE"
sudo gdebi -n rstudio.deb 2>&1 | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm

echo "✅ Instalacja zakończona. XFCE, PyCharm, PlayOnLinux, R i RStudio są gotowe do pracy." | tee -a "$LOGFILE"
