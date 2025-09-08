#!/bin/bash

LOGFILE="install_log.txt"
CONFIG_FILE="$HOME/.config/xfce_installer.conf"
mkdir -p "$(dirname "$CONFIG_FILE")"

PYCHARM_VERSION="2025.2.1.1"
PYCHARM_DIR="/opt/pycharm"
RSTUDIO_URL="https://download1.rstudio.org/electron/jammy/amd64/rstudio-2025.05.1-513-amd64.deb"
CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb"
WEB_APP_MANAGER="http://packages.linuxmint.com/pool/main/w/webapp-manager/webapp-manager_1.4.3_all.deb"


FILES_TO_SOURCE=(
  "./modules/ufw_setup.sh"
  "./modules/emacs_setup.sh"
  "./modules/xfce_setup.sh"
  "./modules/cuda_setup.sh"
  "./modules/pycharm_setup.sh"
  "./modules/rstudio_setup.sh"
  "./modules/nvidia_setup.sh"
  "./modules/docker_setup.sh"
  "./modules/compiz_setup.sh"
  "./modules/user_apps_setup.sh"
  "./modules/grub_setup.sh"
  "./modules/lid_poweroff_setup.sh"
  "./modules/intel_gpu_setup.sh"
  "./modules/printers_setup.sh"
  "./modules/bluetooth_setup.sh"
  "./modules/pulse_audio_setup.sh"
)

for file in "${FILES_TO_SOURCE[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file"
  else
    echo "⚠️ Plik $file nie istnieje, pomijam." | tee -a "$LOGFILE"
  fi
done
