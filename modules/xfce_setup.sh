#!/bin/bash

# 🔍 Funkcja dodająca linię, jeśli jej nie ma
add_if_missing() {
    local line="$1"
    if grep -qxF "$line" "$BASHRC"; then
        echo "⏭️ Pomijam: '$line' już istnieje." | tee -a "$LOGFILE"
    else
        echo "$line" >> "$BASHRC"
        echo "✅ Dodano: $line" | tee -a "$LOGFILE"
    fi
}

configure_lightdm_greeter() {
  echo "🔧 Konfiguracja LightDM: greeter i lista użytkowników..." | tee -a "$LOGFILE"

  CONFIG_DIR="/etc/lightdm"
  CONF_D_DIR="$CONFIG_DIR/lightdm.conf.d"
  CONF_D_FILE="$CONF_D_DIR/01-users.conf"
  MAIN_CONF="$CONFIG_DIR/lightdm.conf"

  # 🔒 Utwórz katalog conf.d jeśli nie istnieje
  if [ ! -d "$CONF_D_DIR" ]; then
    echo "📁 Tworzenie katalogu: $CONF_D_DIR" | tee -a "$LOGFILE"
    sudo mkdir -p "$CONF_D_DIR"
  fi

  # 📝 Dodaj wpisy do 01-users.conf
  echo "📝 Konfiguracja: $CONF_D_FILE" | tee -a "$LOGFILE"
  sudo tee "$CONF_D_FILE" > /dev/null <<EOF
[Seat:*]
greeter-hide-users=false
greeter-show-manual-login=true
EOF
  echo "✅ Zapisano konfigurację w $CONF_D_FILE" | tee -a "$LOGFILE"

  # 🔒 Kopia zapasowa głównego pliku
  if [ -f "$MAIN_CONF" ]; then
    echo "📦 Tworzenie kopii zapasowej: $MAIN_CONF.bak" | tee -a "$LOGFILE"
    sudo cp "$MAIN_CONF" "$MAIN_CONF.bak"
  else
    echo "📄 Plik $MAIN_CONF nie istnieje. Tworzę nowy..." | tee -a "$LOGFILE"
    sudo touch "$MAIN_CONF"
  fi

  # 🚀 Dodaj wpisy do lightdm.conf
  add_if_missing_lightdm "[Seat:*]"
  add_if_missing_lightdm "greeter-session=lightdm-gtk-greeter"
  add_if_missing_lightdm "greeter-hide-users=false"
  add_if_missing_lightdm "greeter-show-manual-login=true"

  echo "✅ Konfiguracja LightDM zakończona pomyślnie." | tee -a "$LOGFILE"
}


install_environment_packages() {
  echo "🛠️ Instalacja pakietów środowiska systemowego..." | tee -a "$LOGFILE"
  sudo apt update
  sudo apt install -y  \
    task-xfce-desktop task-polish-desktop \
    synaptic package-update-indicator \
    openssh-server ufw gufw papirus-icon-theme \
    gdebi-core unattended-upgrades apt-listchanges \
    mintstick timeshift redshift redshift-gtk powermgmt-base \
    libxapp1 gir1.2-xapp-1.0 xapps-common python3-xapp gdebi \
    libimobiledevice-1.0-6 libimobiledevice-utils usbmuxd ifuse isc-dhcp-client \
    network-manager network-manager-gnome \
    firmware-iwlwifi firmware-realtek firmware-brcm80211 \
    gvfs gvfs-backends gvfs-fuse nautilus \
    gnome-system-tools mugshot \
    bleachbit p7zip-full file-roller 2>&1 | tee -a "$LOGFILE"
}



remove_unwanted() {
  echo "🧪 Usuwanie zbędnych pakietów..." | tee -a "$LOGFILE"
  sudo apt remove -y --auto-remove parole ristretto mousepad quodlibethom
}


configure_locale_and_keyboard() {
  echo "🌍 Konfiguracja języka i klawiatury..." | tee -a "$LOGFILE"
  sudo sed -i 's/^# pl_PL.UTF-8 UTF-8/pl_PL.UTF-8 UTF-8/' /etc/locale.gen
  sudo locale-gen
  sudo update-locale LANG=pl_PL.UTF-8

  echo 'setxkbmap -model pc105 -layout pl -variant legacy' >> ~/.xprofile
  chmod +x ~/.xprofile
}


copy_user_config() {
  echo "🗂️ Kopiowanie konfiguracji użytkownika..." | tee -a "$LOGFILE"
  install -d "/home/$(logname)/.config" \
            "home/$(logname)/tapety"

  cp -R config/* "/home/$(logname)/.config"
  cp -R tapety "/home/$(logname)/"
  echo "🔄 Konfiguracja automatycznych aktualizacji..." | tee -a "$LOGFILE"

}

setup_ipad_support() {
    set -e  # Zatrzymaj skrypt przy pierwszym błędzie

    echo "📱 Rozpoczynam konfigurację obsługi iPada w Debianie XFCE..." | tee -a "$LOGFILE"


    # 📁 Tworzenie katalogu montowania dla ręcznego użycia ifuse
    echo "📁 Tworzenie katalogu ~/ipad jako punkt montowania..." | tee -a "$LOGFILE"
    mkdir -p "/home/$(logname)/ipad"
    echo "✔️ Katalog ~/ipad utworzony." | tee -a "$LOGFILE"

    # 🔍 Test obecności narzędzi
    echo "🔍 Sprawdzanie dostępności poleceń..." | tee -a "$LOGFILE"
    for cmd in ideviceinfo ifuse usbmuxd; do
        if command -v "$cmd" >/dev/null; then
            echo "✅ $cmd dostępne." | tee -a "$LOGFILE"
        else
            echo "❌ $cmd nie znaleziono — sprawdź instalację." | tee -a "$LOGFILE"
        fi
    done

    echo "📜 Upewnij się, że po podłączeniu iPada zaakceptujesz komunikat 'Zaufaj temu komputerowi' na urządzeniu." | tee -a "$LOGFILE"
    echo "📁 Po podłączeniu możesz ręcznie zamontować iPada poleceniem: ifuse ~/ipad" | tee -a "$LOGFILE"
    echo "✅ Konfiguracja zakończona pomyślnie!" | tee -a "$LOGFILE"
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
          com.ktechpit.whatsie \
          app/io.missioncenter.MissionCenter/x86_64/stable \
          app/com.playonlinux.PlayOnLinux4/x86_64/stable | tee -a "$LOGFILE"

  echo "✅ Aplikacje zostały zainstalowane." | tee -a "$LOGFILE"

}

configure_xfce() {
  install_environment_packages
  remove_unwanted
  configure_locale_and_keyboard
  copy_user_config
  setup_unattended_upgrades
  configure_lightdm_greeter
  configure_flatpak
  echo "✅ Konfiguracja XFCE zakończona!" | tee -a "$LOGFILE"
}

