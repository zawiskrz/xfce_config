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

FILES_TO_SOURCE=(
  "./ufw_setup.sh"
  "./smb_setup.sh"
  "./emacs_setup.sh"
  "./xfce_setup.sh"
  "./cuda_setup.sh"
  "./pycharm_setup.sh"
  "./rstudio_setup.sh"
  "./nvidia_setup.sh"
)

for file in "${FILES_TO_SOURCE[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo "⚠️ Plik $file nie istnieje, pomijam." | tee -a "$LOGFILE"
  fi
done

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 22 76 16)
options=(
  1 "Środowisko XFCE" on
  2 "Sterowniki NVIDIA" off
  3 "CUDA Toolkit" off
  4 "PyCharm" off
  5 "RStudio" off
  6 "Emacs" off
  7 "Samba + udostępnienia" off
  8 "Firewall" on
  9 "Restart X11" off
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
    4) echo "PYCHARM=true" >> "$CONFIG_FILE" ;;
    5) echo "RSTUDIO=true" >> "$CONFIG_FILE" ;;
    6) echo "EMACS=true" >> "$CONFIG_FILE" ;;
    7) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    8) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    9) echo "lIGHTDM=true" >> "$CONFIG_FILE" ;;
  esac
done

# Wykonanie instalacji na podstawie konfiguracji
source "$CONFIG_FILE"

if [[ "$XFCE" == "true" ]]; then
  configure_xfce
fi

if [[ "$NVIDIA" == "true" ]]; then
  configure_nvidia
fi

if [[ "$CUDA" == "true" ]]; then
  configure_cuda
fi

if [[ "$PYCHARM" == "true" ]]; then
  configure_pycharm
fi

if [[ "$RSTUDIO" == "true" ]]; then
 configure_rstudio
fi

if [[ "$EMACS" == "true" ]]; then

  configure_emacs
fi

if [[ "$SAMBA" == "true" ]]; then
  configure_smb
fi

if [[ "$FIREWALL" == "true" ]]; then
  configure_ufw
fi

if [[ "$lIGHTDM" == "true" ]]; then
  echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
  sudo systemctl restart lightdm
fi

echo "✅ Instalacja zakończona. Wybrane komponenty zostały zainstalowane." | tee -a "$LOGFILE"
