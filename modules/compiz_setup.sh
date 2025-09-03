#!/bin/bash


setup_compiz_for_xfce() {
    set -e  # Zatrzymaj skrypt przy błędzie

    echo "🎨 Instalacja Compiz i komponentów..." | tee -a "$LOGFILE"
    sudo apt install -y compiz compiz-plugins compiz-plugins-main compiz-plugins-extra compizconfig-settings-manager fusion-icon gnome-themes-standard 2>&1 | tee -a "$LOGFILE"

    echo "🧱 Tworzenie katalogu konfiguracyjnego Compiz..." | tee -a "$LOGFILE"
    install -d "/home/$(logname)/.config/compiz" | tee -a "$LOGFILE"

    echo "🧩 Ustawianie lekkiego zestawu wtyczek..." | tee -a "$LOGFILE"
    gsettings set org.compiz.core:/org/compiz/profiles/xfce/plugins/core/ active-plugins "['core', 'composite', 'opengl', 'move', 'resize', 'place', 'decoration', 'mousepoll', 'grid', 'staticswitcher']" 2>&1 | tee -a "$LOGFILE"

    echo "🎛️ Konfiguracja Static Application Switcher..." | tee -a "$LOGFILE"
    gsettings set org.compiz.staticswitcher:/org/compiz/profiles/xfce/plugins/staticswitcher/ show-preview false 2>&1 | tee -a "$LOGFILE"
    gsettings set org.compiz.staticswitcher:/org/compiz/profiles/xfce/plugins/staticswitcher/ show-icons true 2>&1 | tee -a "$LOGFILE"
    gsettings set org.compiz.staticswitcher:/org/compiz/profiles/xfce/plugins/staticswitcher/ background-color "#000000cc" 2>&1 | tee -a "$LOGFILE"

    echo "⌨️ Przypisywanie skrótu Alt+Tab do przełączania okien..." | tee -a "$LOGFILE"
    gsettings set org.compiz.staticswitcher:/org/compiz/profiles/xfce/plugins/staticswitcher/ next-key "<Alt>Tab" 2>&1 | tee -a "$LOGFILE"
    gsettings set org.compiz.staticswitcher:/org/compiz/profiles/xfce/plugins/staticswitcher/ prev-key "<Shift><Alt>Tab" 2>&1 | tee -a "$LOGFILE"

    echo "🖥️ Konfiguracja XFCE do używania Compiz jako menedżera okien..." | tee -a "$LOGFILE"
    xfconf-query -c xfwm4 -p /general/replace -s false 2>&1 | tee -a "$LOGFILE"
    xfconf-query -c xfce4-session -p /sessions/XFCE/Client0_Command -s "compiz" 2>&1 | tee -a "$LOGFILE"

    echo "🧠 Dodawanie Fusion Icon do autostartu..." | tee -a "$LOGFILE"
    mkdir -p "/home/$(logname)/.config/autostart"
    cat <<EOF > "/home/$(logname)/.config/autostart/fusion-icon.desktop"
[Desktop Entry]
Type=Application
Exec=fusion-icon
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Fusion Icon
Comment=Compiz tray manager
EOF

    echo "🚀 Restartowanie sesji XFCE może być wymagane, aby Compiz przejął kontrolę nad oknami." | tee -a "$LOGFILE"
    echo "✅ Konfiguracja Compiz z Static Switcher zakończona pomyślnie!" | tee -a "$LOGFILE"
}

