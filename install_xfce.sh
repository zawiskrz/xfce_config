#!/bin/bash

LOGFILE="install_log.txt"
PYCHARM_VERSION="2025.1"
PYCHARM_DIR="/opt/pycharm"
RSTUDIO_URL="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.04.1-748-amd64.deb"
PLAYONLINUX_URL="https://www.playonlinux.com/script_files/PlayOnLinux/4.3.4/PlayOnLinux_4.3.4.deb"
CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb"
ONEAPI_INSTALLER="l_BaseKit_p_2025.1.0.495_offline.sh"
ONEAPI_URL="https://registrationcenter-download.intel.com/akdlm/irc_nas/19184/${ONEAPI_INSTALLER}"
SAMBA_USER="smbuser"
SAMBA_PASS="smbuser"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska graficznego XFCE..." | tee -a "$LOGFILE"
sudo apt install -y \
task-xfce-desktop menulibre \
openssh-server ufw samba \
network-manager-gnome bluez blueman \
pulseaudio pulseaudio-utils pulseaudio-module-bluetooth pavucontrol libcanberra-pulse \
firefox-esr thunderbird vlc calibre rhythmbox shotwell \
libreoffice libreoffice-l10n-pl libreoffice-help-pl \
wxmaxima python3 python3-pip python3-venv \
r-base r-base-dev r-recommended \
mc htop x11-xserver-utils papirus-icon-theme wget curl gdebi-core 2>&1 | tee -a "$LOGFILE"

echo "🧠 Instalacja sterowników Intel..." | tee -a "$LOGFILE"
sudo apt install -y intel-microcode firmware-misc-nonfree 2>&1 | tee -a "$LOGFILE"

echo "🎮 Instalacja sterowników NVIDIA..." | tee -a "$LOGFILE"
sudo apt install -y nvidia-detect 2>&1 | tee -a "$LOGFILE"
if nvidia-detect | grep -q "recommended"; then
  echo "🖥️ Wykryto kartę NVIDIA – instalacja sterownika..." | tee -a "$LOGFILE"
  sudo apt install -y nvidia-driver nvidia-settings 2>&1 | tee -a "$LOGFILE"
else
  echo "ℹ️ Nie wykryto kompatybilnej karty NVIDIA lub sterownik nie jest zalecany." | tee -a "$LOGFILE"
fi

echo "⚡ Instalacja CUDA Toolkit..." | tee -a "$LOGFILE"
wget "$CUDA_KEYRING_URL" -O cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
sudo dpkg -i cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
sudo apt update
sudo apt install -y cuda 2>&1 | tee -a "$LOGFILE"
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

echo "🧠 Instalacja Intel oneAPI Base Toolkit..." | tee -a "$LOGFILE"
wget "$ONEAPI_URL" -O "$ONEAPI_INSTALLER" 2>&1 | tee -a "$LOGFILE"
chmod +x "$ONEAPI_INSTALLER"
sudo ./"$ONEAPI_INSTALLER" --silent --eula accept 2>&1 | tee -a "$LOGFILE"
echo 'source /opt/intel/oneapi/setvars.sh' >> ~/.bashrc

echo "📁 Tworzenie użytkownika Samba..." | tee -a "$LOGFILE"
sudo useradd -m -s /bin/bash "$SAMBA_USER"
echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo passwd "$SAMBA_USER"
echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a "$SAMBA_USER"
sudo smbpasswd -e "$SAMBA_USER"

echo "📁 Tworzenie katalogów do udostępnienia..." | tee -a "$LOGFILE"
mkdir -p /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
chmod 770 /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
chown $SAMBA_USER:$SAMBA_USER /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo

echo "🛠️ Konfiguracja Samby z autoryzacją..." | tee -a "$LOGFILE"
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat <<EOF | sudo tee -a /etc/samba/smb.conf

[Obrazy]
   path = /home/$SAMBA_USER/Obrazy
   valid users = $SAMBA_USER
   browseable = yes
   writable = yes
   create mask = 0770
   directory mask = 0770

[Wideo]
   path = /home/$SAMBA_USER/Wideo
   valid users = $SAMBA_USER
   browseable = yes
   writable = yes
   create mask = 0770
   directory mask = 0770
EOF

echo "🔁 Restartowanie Samby..." | tee -a "$LOGFILE"
sudo systemctl restart smbd

echo "🛡️ Konfiguracja zapory UFW..." | tee -a "$LOGFILE"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

for subnet in 192.168.0.0/24 192.168.1.0/24; do
  for port in 22 139 445 1716; do
    sudo ufw allow from $subnet to any port $port proto tcp
  done
  for port in 137 138; do
    sudo ufw allow from $subnet to any port $port proto udp
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

echo "🍷 Instalacja Wine i architektury 32-bitowej..." | tee -a "$LOGFILE"
sudo dpkg --add-architecture i386
sudo apt update 2>&1 | tee -a "$LOGFILE"
sudo apt install -y wine wine32 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja PlayOnLinux..." | tee -a "$LOGFILE"
wget "$PLAYONLINUX_URL" -O playonlinux.deb 2>&1 | tee -a "$LOGFILE"
sudo gdebi -n playonlinux.deb 2>&1 | tee -a "$LOGFILE"

echo "🧪 Instalacja RStudio..." | tee -a "$LOGFILE"
wget "$RSTUDIO_URL" -O rstudio.deb 2>&1 | tee -a "$LOGFILE"
sudo gdebi -n rstudio.deb 2>&1 | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm

echo "✅ Instalacja zakończona. XFCE, PyCharm, PlayOnLinux, R, RStudio, CUDA, oneAPI i Samba są gotowe do pracy." | tee -a "$LOGFILE"
