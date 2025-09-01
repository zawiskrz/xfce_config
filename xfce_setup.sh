#!/bin/bash

configure_xfce() {
    echo "📦 Instalacja XFCE i konfiguracja języka..." | tee -a "$LOGFILE"
  sudo apt install -y \
    task-xfce-desktop menulibre gnome-package-updater \
    bluez blueman pulseaudio pulseaudio-utils pulseaudio-module-bluetooth rfkill \
    keyboard-configuration console-setup locales \
    task-polish-desktop \
    thunderbird vlc calibre rhythmbox shotwell \
    libreoffice-l10n-pl libreoffice-help-pl \
    wxmaxima python3 python3-pip python3-venv \
    mc htop wget curl gdebi-core \
    remmina filezilla gparted mintstick gnome-calculator \
    openssh-server ufw papirus-icon-theme 2>&1 | tee -a "$LOGFILE"

  echo "🧪 Usuwanie nadmiarowego oprogramowania " | tee -a "$LOGFILE"
  sudo apt purge -y --auto-remove parole quod-libet  ristretto mousepad

  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
  sudo rfkill unblock bluetooth

  echo "🔊 Konfiguracja globalnego autostartu PulseAudio..." | tee -a "$LOGFILE"
  sudo mkdir -p /etc/xdg/autostart
  sudo bash -c 'cat > /etc/xdg/autostart/pulseaudio.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Exec=pulseaudio --start
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name=PulseAudio
    Comment=Start PulseAudio sound server
    EOF'

  echo "🌍 Ustawianie języka polskiego i klawiatury..." | tee -a "$LOGFILE"
  sudo sed -i 's/^# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen
  sudo update-locale LANG=pl_PL.UTF-8
  sudo localectl set-locale LANG=pl_PL.UTF-8
  sudo localectl set-keymap pl
  sudo localectl set-x11-keymap pl pc105 legacy

  # Ustawienie klawiatury po starcie X11
  echo 'setxkbmap -model pc105 -layout pl -variant legacy' >> ~/.xprofile
  chmod +x ~/.xprofile



  echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
  install -d ~/.config/gtk-3.0 ~/.local/share/rhythmbox ~/tapety
  cp -f config/gtk-3.0/* ~/.config/gtk-3.0/
  cp -f local/rhythmbox/* ~/.local/share/rhythmbox/
  cp -f tapety/* ~/tapety/
}