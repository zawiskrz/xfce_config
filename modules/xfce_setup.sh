#!/bin/bash

install_environment_packages() {
  echo "🛠️ Instalacja pakietów środowiska systemowego..." | tee -a "$LOGFILE"
  sudo apt update
  sudo apt install -y \
    task-xfce-desktop task-polish-desktop synaptic package-update-indicator \
    bluez blueman pulseaudio pulseaudio-utils pulseaudio-module-bluetooth rfkill \
    language-pack-pl keyboard-configuration console-setup locales \
    openssh-server ufw gufw papirus-icon-theme \
    unattended-upgrades policykit-1 gdebi-core \
    gnome-calculator gparted mintstick timeshift 2>&1 | tee -a "$LOGFILE"
}

install_user_apps() {
  echo "🎯 Instalacja dodatkowego oprogramowania użytkowego..." | tee -a "$LOGFILE"
  sudo apt install -y \
    menulibre thunderbird vlc calibre rhythmbox shotwell \
    libreoffice-l10n-pl libreoffice-help-pl \
    wxmaxima python3 python3-pip python3-venv \
    mc htop wget curl \
    remmina filezilla 2>&1 | tee -a "$LOGFILE"
}

remove_unwanted() {
  echo "🧪 Usuwanie zbędnych pakietów..." | tee -a "$LOGFILE"
  sudo apt purge -y --auto-remove parole quod-libet ristretto mousepad
}

configure_bluetooth() {
  echo "🔵 Konfiguracja Bluetooth..." | tee -a "$LOGFILE"
  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
  sudo rfkill unblock bluetooth
}

setup_pulseaudio_autostart() {
  echo "🔊 Autostart PulseAudio..." | tee -a "$LOGFILE"
  sudo mkdir -p /etc/xdg/autostart
  sudo tee /etc/xdg/autostart/pulseaudio.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=pulseaudio --start
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=PulseAudio
Comment=Start PulseAudio sound server
EOF
}

configure_locale_and_keyboard() {
  echo "🌍 Konfiguracja języka i klawiatury..." | tee -a "$LOGFILE"
  sudo sed -i 's/^# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen
  sudo update-locale LANG=pl_PL.UTF-8
  sudo localectl set-locale LANG=pl_PL.UTF-8
  sudo localectl set-keymap pl
  sudo localectl set-x11-keymap pl pc105 legacy

  echo 'setxkbmap -model pc105 -layout pl -variant legacy' >> ~/.xprofile
  chmod +x ~/.xprofile
}

copy_user_config() {
  echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
  install -d ~/.config/gtk-3.0 ~/.local/share/rhythmbox ~/tapety
  cp -f config/gtk-3.0/* ~/.config/gtk-3.0/
  cp -f local/rhythmbox/* ~/.local/share/rhythmbox/
  sudo mkdir -p /usr/share/backgrounds/moje-tapety
  sudo cp -f tapety/* /usr/share/backgrounds/moje-tapety/

}

configure_updates() {
  echo "🔄 Konfiguracja automatycznych aktualizacji..." | tee -a "$LOGFILE"

  # Aktywacja unattended-upgrades
  sudo dpkg-reconfigure -plow unattended-upgrades

  # Dodanie package-update-indicator do autostartu
  mkdir -p ~/.config/autostart
  tee ~/.config/autostart/package-update-indicator.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=package-update-indicator
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Aktualizacje systemu
Comment=Powiadomienia o dostępnych aktualizacjach
EOF

  # Ustawienie Synaptic jako domyślnego menedżera aktualizacji
  mkdir -p ~/.config/package-update-indicator
  tee ~/.config/package-update-indicator/settings.conf > /dev/null <<EOF
[General]
update-viewer=synaptic-pkexec
check-interval=daily
EOF
}

configure_flatpak() {
  echo "📦 Instalacja Flatpak i dodanie Flathub..." | tee -a "$LOGFILE"

  # Instalacja Flatpak i integracji z GUI
  sudo apt update
  sudo apt install -y flatpak  | tee -a "$LOGFILE"
  # duże zuzucie RAMu po instalacji gnome-software gnome-software-plugin-flatpak
  # Dodanie repozytorium Flathub
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  echo "✅ Flatpak skonfigurowany z Flathub." | tee -a "$LOGFILE"

  echo "📥 Instalacja aplikacji z Flathub .." | tee -a "$LOGFILE"

  # Instalacja aplikacji
  flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux \
          app.ytmdesktop.ytmdesktop \
          com.github.unrud.VideoDownloader \
          io.github.amit9838.mousam \
          com.ktechpit.whatsie | tee -a "$LOGFILE"

  echo "✅ Aplikacje zostały zainstalowane." | tee -a "$LOGFILE"

}

configure_redshift(){
  echo "🌇 Instalacja Redshift..." | tee -a "$LOGFILE"
  sudo apt install -y redshift redshift-gtk | tee -a "$LOGFILE"

  echo "📍 Tworzenie konfiguracji dla Szczecina..." | tee -a "$LOGFILE"
  mkdir -p ~/.config

  cat <<EOF > ~/.config/redshift.conf
[redshift]
temp-day=5700
temp-night=3500
transition=1
brightness=0.9

[manual]
lat=53.42894
lon=14.55302
EOF

  echo "✅ Konfiguracja zapisana w ~/.config/redshift.conf" | tee -a "$LOGFILE"

  # Opcjonalnie dodaj do autostartu
  AUTOSTART_DIR="$HOME/.config/autostart"
  mkdir -p "$AUTOSTART_DIR"

  cat <<EOF > "$AUTOSTART_DIR/redshift.desktop"
[Desktop Entry]
Type=Application
Exec=redshift-gtk -c ~/.config/redshift.conf
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Redshift
Comment=Automatyczne dostosowanie barw ekranu
EOF

  echo "🔁 Dodano Redshift do autostartu." | tee -a "$LOGFILE"
  echo "🎉 Gotowe! Redshift działa z ustawieniami dla Szczecina." | tee -a "$LOGFILE"

}

configure_xfce() {
  install_environment_packages
  install_user_apps
  remove_unwanted
  configure_bluetooth
  setup_pulseaudio_autostart
  configure_locale_and_keyboard
  copy_user_config
  configure_updates
  configure_flatpak
  configure_redshift
  echo "✅ Konfiguracja XFCE zakończona!" | tee -a "$LOGFILE"
}

