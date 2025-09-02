#!/bin/bash

install_environment_packages() {
  echo "🛠️ Instalacja pakietów środowiska systemowego..." | tee -a "$LOGFILE"
  sudo apt update
  sudo apt install -y  \
    task-xfce-desktop task-polish-desktop \
    synaptic package-update-indicator \
    bluez blueman pulseaudio-module-bluetooth rfkill \
    openssh-server ufw gufw papirus-icon-theme \
    gdebi-core unattended-upgrades apt-listchanges \
    mintstick timeshift redshift redshift-gtk powermgmt-base \
    bleachbit p7zip-full file-roller 2>&1 | tee -a "$LOGFILE"
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
  sudo apt purge -y --auto-remove parole ristretto mousepad quodlibet
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
  install -d "/home/$(logname)/.config" \
            "/home/$(logname)/.local/share/rhythmbox" \
            "home/$(logname)/tapety"

  cp -R config/* "/home/$(logname)/.config"
  cp -f local/rhythmbox/* "/home/$(logname)/.local/share/rhythmbox/"
  sudo cp -R tapety "/home/$(logname)/"
  echo "🔄 Konfiguracja automatycznych aktualizacji..." | tee -a "$LOGFILE"

}

setup_unattended_upgrades() {
    set -e  # Zatrzymaj skrypt przy pierwszym błędzie

    echo "📁 Tworzenie pliku 50unattended-upgrades..." | tee -a "$LOGFILE"
    sudo tee /etc/apt/apt.conf.d/50unattended-upgrades > /dev/null <<EOF
Unattended-Upgrade::Allowed-Origins {
    "Debian stable";
    "Debian stable-updates";
    "Debian-security stable-security";
};

Unattended-Upgrade::Package-Blacklist {
};

Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF
    echo "✔️ Plik 50unattended-upgrades utworzony." | tee -a "$LOGFILE"

    echo "🕒 Tworzenie pliku 20auto-upgrades..." | tee -a "$LOGFILE"
    sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null <<EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
    echo "✔️ Plik 20auto-upgrades utworzony." | tee -a "$LOGFILE"

    echo "🚀 Włączanie i restartowanie usługi..." | tee -a "$LOGFILE"
    sudo systemctl enable unattended-upgrades 2>&1 | tee -a "$LOGFILE"
    sudo systemctl restart unattended-upgrades 2>&1 | tee -a "$LOGFILE"
    echo "✔️ Usługa unattended-upgrades aktywna." | tee -a "$LOGFILE"

    echo "🔍 Test działania (tryb debugowania)..." | tee -a "$LOGFILE"
    if sudo unattended-upgrade -d 2>&1 | tee -a "$LOGFILE"; then
        echo "✅ Test zakończony pomyślnie." | tee -a "$LOGFILE"
    else
        echo "⚠️ Test zakończony z błędami — sprawdź logi." | tee -a "$LOGFILE"
    fi

    echo "📜 Logi: /var/log/unattended-upgrades/" | tee -a "$LOGFILE"
    echo "✅ Konfiguracja zakończona pomyślnie!" | tee -a "$LOGFILE"
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



configure_xfce() {
  install_environment_packages
  install_user_apps
  remove_unwanted
  configure_bluetooth
  setup_pulseaudio_autostart
  configure_locale_and_keyboard
  copy_user_config
  setup_unattended_upgrades
  configure_flatpak
  echo "✅ Konfiguracja XFCE zakończona!" | tee -a "$LOGFILE"
}

