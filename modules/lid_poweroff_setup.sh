#!/bin/bash

configure_lid_poweroff() {
    echo "🔧 Konfiguruję zachowanie ekranów w zależności od stanu pokrywy..."

    # 1. Modyfikacja logind.conf – ignorujemy zamknięcie pokrywy
    local config_file="/etc/systemd/logind.conf"
    local backup_file="/etc/systemd/logind.conf.bak"

    echo "📁 Tworzę kopię zapasową: $backup_file"
    sudo cp "$config_file" "$backup_file"

    echo "📝 Ustawiam HandleLidSwitch=ignore"
    sudo sed -i '/^HandleLidSwitch=/d' "$config_file"
    sudo sed -i '/^HandleLidSwitchExternalPower=/d' "$config_file"
    echo "HandleLidSwitch=ignore" | sudo tee -a "$config_file" > /dev/null
    echo "HandleLidSwitchExternalPower=ignore" | sudo tee -a "$config_file" > /dev/null

    echo "🔄 Restartuję systemd-logind..."
    sudo systemctl restart systemd-logind

    # 2. Instalacja acpid (jeśli nie ma)
    echo "📦 Instaluję acpid..."
    sudo apt install -y acpid
    sudo systemctl enable acpid
    sudo systemctl start acpid

    # 3. Skrypt do przełączania ekranów
    local script_path="/usr/local/bin/lid-monitor-switch.sh"
    sudo tee "$script_path" > /dev/null <<'EOF'
#!/bin/bash

# Pobierz nazwę aktywnego użytkownika
USER=$(logname)

# Ustaw zmienne środowiskowe dla sesji graficznej
export DISPLAY=$(pgrep -a X | grep "$USER" | awk '{print $NF}')
export XAUTHORITY="/home/$USER/.Xauthority"

# Pobierz stan pokrywy
LID_STATE=$(cat /proc/acpi/button/lid/LID*/state | awk '{print $2}')

# Wykryj nazwę ekranu laptopa i zewnętrznego monitora
LAPTOP=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | awk '{print $1}')
EXTERNAL=$(xrandr | grep " connected" | grep -vE "eDP|LVDS" | awk '{print $1}')

# Sprawdź, czy oba ekrany są wykryte
if [ -z "$LAPTOP" ] || [ -z "$EXTERNAL" ]; then
    echo "❌ Nie wykryto ekranów. Przerywam."
    exit 1
fi

# Przełączanie ekranów w zależności od stanu pokrywy
if [ "$LID_STATE" = "closed" ]; then
    echo "🔒 Pokrywa zamknięta – wyłączam ekran laptopa"
    xrandr --output "$LAPTOP" --off --output "$EXTERNAL" --auto
else
    echo "📖 Pokrywa otwarta – włączam oba ekrany"
    xrandr --output "$LAPTOP" --auto --output "$EXTERNAL" --auto
fi
EOF

    sudo chmod +x "$script_path"

    # 4. Reguła ACPI do wywoływania skryptu przy zmianie stanu pokrywy
    local acpi_event_file="/etc/acpi/events/lid-monitor"
    sudo tee "$acpi_event_file" > /dev/null <<EOF
event=button/lid.*
action=su -l $(logname) -c "$script_path"
EOF

    echo "🔄 Restartuję acpid, aby załadować nową regułę..."
    sudo systemctl restart acpid

    echo "✅ Gotowe! System będzie dynamicznie przełączał ekrany w zależności od stanu pokrywy laptopa."
}
