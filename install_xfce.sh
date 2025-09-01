#!/bin/bash
source "./config.sh"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja narzędzi interaktywnych..." | tee -a "$LOGFILE"
sudo apt install -y dialog 2>&1 | tee -a "$LOGFILE"

# Interaktywne menu
cmd=(dialog --separate-output --checklist "Wybierz komponenty do instalacji:" 22 76 16)
options=(
  1 "XFCE" on
  2 "[PROGRAMOWANIE] RStudio" off
  3 "[PROGRAMOWANIE] PyCharm" off
  4 "[PROGRAMOWANIE] Emacs" off
  5 "[SYSTEM] Samba" off
  6 "[SYSTEM] Firewall" on
  7 "[SYSTEM] Docker" off
  8 "[SYSTEM] NVIDIA" off
  9 "[SYSTEM] CUDA Toolkit" off
  10 "Restart X11" off
)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Zapis konfiguracji
echo "# Konfiguracja instalatora XFCE" > "$CONFIG_FILE"
for choice in $choices; do
  case $choice in
    1) echo "XFCE=true" >> "$CONFIG_FILE" ;;
    2) echo "RSTUDIO=true" >> "$CONFIG_FILE" ;;
    3) echo "PYCHARM=true" >> "$CONFIG_FILE" ;;
    4) echo "EMACS=true" >> "$CONFIG_FILE" ;;
    5) echo "SAMBA=true" >> "$CONFIG_FILE" ;;
    6) echo "FIREWALL=true" >> "$CONFIG_FILE" ;;
    7) echo "DOCKER=true" >> "$CONFIG_FILE" ;;
    8) echo "NVIDIA=true" >> "$CONFIG_FILE" ;;
    9) echo "CUDA=true" >> "$CONFIG_FILE" ;;
    10) echo "lIGHTDM=true" >> "$CONFIG_FILE" ;;
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
  SAMBA_USER="$(logname)"
  #Koniecznie należy podać hasło dla użytkownia
  read -s -p "🔑 Podaj hasło dla użytkownika Samba: " SAMBA_PASS
  echo
  source  "./modules/smb_setup.sh"
  configure_smb
fi

if [[ "$FIREWALL" == "true" ]]; then
  configure_ufw
fi

if [[ "$DOCKER" == "true" ]]; then
  configure_docker
fi


if [[ "$lIGHTDM" == "true" ]]; then
  echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
  sudo systemctl restart lightdm
fi

echo "✅ Instalacja zakończona. Wybrane komponenty zostały zainstalowane." | tee -a "$LOGFILE"
