#!/bin/bash

LOGFILE="install_log.txt"
CONFIG_FILE="$HOME/.config/xfce_installer.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

PYCHARM_VERSION="2025.1"
PYCHARM_DIR="/opt/pycharm"
RSTUDIO_URL="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2025.05.1-513-amd64.deb"
PLAYONLINUX_URL="https://www.playonlinux.com/script_files/PlayOnLinux/4.3.4/PlayOnLinux_4.3.4.deb"
CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb"
ONEAPI_INSTALLER="l_BaseKit_p_2025.1.0.495_offline.sh"
ONEAPI_URL="https://registrationcenter-download.intel.com/akdlm/irc_nas/19184/${ONEAPI_INSTALLER}"
SAMBA_USER="smbuser"
SAMBA_PASS="smbuser"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 22 76 16)
options=(
  1 "Środowisko XFCE" off
  2 "Sterowniki NVIDIA" off
  3 "CUDA Toolkit" off
  4 "Intel oneAPI" off
  5 "PyCharm" off
  6 "RStudio" off
  7 "Samba + udostępnienia" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Zapis konfiguracji
echo "# Konfiguracja instalatora XFCE" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "XFCE=true" >> "$CONFIG_FILE" ;;
    2) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    3) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    5) echo "PYCHARM=true" >> "$CONFIG_FILE" ;;
    6) echo "RSTUDIO=true" >> "$CONFIG_FILE" ;;
    7) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wykonanie instalacji na podstawie konfiguracji
source "$CONFIG_FILE"

if [[ "$XFCE" == "true" ]]; then
  echo "📦 Instalacja XFCE i konfiguracja języka..." | tee -a "$LOGFILE"
  sudo apt install -y \
    task-xfce-desktop menulibre \
    bluez blueman pulseaudio pulseaudio-utils pulseaudio-module-bluetooth rfkill \
    keyboard-configuration console-setup locales \
    task-polish-desktop \
    thunderbird vlc calibre rhythmbox shotwell \
    libreoffice-l10n-pl libreoffice-help-pl \
    wxmaxima python3 python3-pip python3-venv \
    mc htop wget curl gdebi-core openssh-server ufw papirus-icon-theme 2>&1 | tee -a "$LOGFILE"

  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
  sudo rfkill unblock bluetooth

  echo "🌍 Ustawianie języka polskiego i klawiatury..." | tee -a "$LOGFILE"
  sudo sed -i 's/^# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen
  sudo update-locale LANG=pl_PL.UTF-8
  sudo localectl set-locale LANG=pl_PL.UTF-8
  sudo localectl set-keymap pl
  sudo localectl set-x11-keymap pl pc105 legacy


  echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
  install -d ~/.config/gtk-3.0 ~/.local/share/rhythmbox ~/tapety
  cp -f config/gtk-3.0/* ~/.config/gtk-3.0/
  cp -f local/rhythmbox/* ~/.local/share/rhythmbox/
  cp -f tapety/* ~/tapety/


fi

if [[ "$NVIDIA" == "true" ]]; then
  echo "🎮 Instalacja sterowników NVIDIA..." | tee -a "$LOGFILE"
  sudo apt install -y nvidia-detect 2>&1 | tee -a "$LOGFILE"
  if nvidia-detect | grep -q "recommended"; then
    sudo apt install -y nvidia-driver nvidia-settings 2>&1 | tee -a "$LOGFILE"
  fi
fi

if [[ "$CUDA" == "true" ]]; then
  echo "⚡ Instalacja CUDA Toolkit..." | tee -a "$LOGFILE"
  wget "$CUDA_KEYRING_URL" -O cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
  sudo dpkg -i cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
  sudo apt update
  sudo apt install -y cuda 2>&1 | tee -a "$LOGFILE"
  echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
fi



if [[ "$PYCHARM" == "true" ]]; then
  echo "🐍 Instalacja PyCharma..." | tee -a "$LOGFILE"
  wget https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz -O pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  tar -xzf pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  sudo mv pycharm-community-${PYCHARM_VERSION} "$PYCHARM_DIR"
  cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Name=PyCharm Community
Exec=${PYCHARM_DIR}/bin/pycharm.sh
Icon=${PYCHARM_DIR}/bin/pycharm.png
Type=Application
Categories=Development;IDE;
EOF
fi

if [[ "$RSTUDIO" == "true" ]]; then
  echo "🧪 Instalacja R 4.4.0 i RStudio..." | tee -a "$LOGFILE"

  # Wymuszenie klasycznego GPG zamiast Sequoia (apt.conf.d)
  echo 'Binary::apt::Acquire::GPGV::Options "--use-legacy-gpg";' | \
    sudo tee /etc/apt/apt.conf.d/99legacy-gpg > /dev/null

  # Instalacja narzędzi do obsługi kluczy
  sudo apt install -y dirmngr gnupg ca-certificates | tee -a "$LOGFILE"

  # Dodanie klucza CRAN ręcznie
  gpg --keyserver keyserver.ubuntu.com --recv-keys 7BA040A510E4E66ED3743EC1B8F25A8A73EACF41
  gpg --export 7BA040A510E4E66ED3743EC1B8F25A8A73EACF41 | \
    sudo tee /etc/apt/trusted.gpg.d/cran.gpg > /dev/null

  # Dodanie repozytorium CRAN dla Debiana 13
  echo "deb https://cloud.r-project.org/bin/linux/debian trixie-cran40/" | \
    sudo tee /etc/apt/sources.list.d/cran.list > /dev/null

  # Aktualizacja listy pakietów
  sudo apt update | tee -a "$LOGFILE"

  # Instalacja R 4.4.0 i zależności
  sudo apt install -y r-base r-base-dev gdebi-core libclang-dev libssl-dev | tee -a "$LOGFILE"

  # Pobranie i instalacja RStudio
  wget "$RSTUDIO_URL" -O rstudio.deb | tee -a "$LOGFILE"
  sudo gdebi -n rstudio.deb | tee -a "$LOGFILE"

  # Weryfikacja wersji R
  echo "📋 Zainstalowana wersja R:" | tee -a "$LOGFILE"
  R --version | tee -a "$LOGFILE"
fi


if [[ "$SAMBA" == "true" ]]; then
  echo "📡 Instalacja Samby z autoryzacją..." | tee -a "$LOGFILE"
  sudo apt install -y samba 2>&1 | tee -a "$LOGFILE"
  sudo useradd -m -s /bin/bash "$SAMBA_USER"
  echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo passwd "$SAMBA_USER"
  echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a "$SAMBA_USER"
  sudo smbpasswd -e "$SAMBA_USER"
  mkdir -p /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
  chmod 770 /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
  chown $SAMBA_USER:$SAMBA_USER /home/$SAMBA_USER/Obrazy /home/$SAMBA_USER/Wideo
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
  sudo systemctl restart smbd
fi

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

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm

echo "✅ Instalacja zakończona. Wybrane komponenty zostały zainstalowane." | tee -a "$LOGFILE"
