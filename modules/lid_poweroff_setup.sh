#!/bin/bash

configure_lid_poweroff() {
configure_lid_display_behavior() {
    echo "🔧 Konfiguruję zachowanie ekranów w zależności od stanu pokrywy..."

    # 1. Ignorowanie zamknięcia pokrywy w systemd-logind
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

    # 2. Instalacja i uruchomienie acpid
    echo "📦 Instaluję acpid..."
    sudo apt install -y acpid
    sudo systemctl enable acpid
    sudo systemctl start acpid

    # 3. Skrypt do przełączania ekranów
    local script_path="/usr/local/bin/lid-monitor-switch.sh"
    local user_name=$(logname)
    sudo tee "$script_path" > /dev/null <<EOF
#!/bin/bash

export DISPLAY=:0
export XAUTHORITY="/home/$user_name/.Xauthority"

LID_STATE=\$(cat /proc/acpi/button/lid/LID*/state | awk '{print \$2}')
LAPTOP=\$(xrandr --query | grep " connected" | grep -E "eDP|LVDS" | awk '{print \$1}')
EXTERNAL=\$(xrandr --query | grep " connected" | grep -vE "eDP|LVDS" | awk '{print \$1}')

if [ -z "\$LAPTOP" ] || [ -z "\$EXTERNAL" ]; then
    echo "❌ Nie wykryto ekranów. Przerywam."
    exit 1
fi

if [ "\$LID_STATE" = "closed" ]; then
    echo "🔒 Pokrywa zamknięta – używam tylko zewnętrznego monitora"
    xrandr --output "\$LAPTOP" --off --output "\$EXTERNAL" --auto --primary
else
    echo "📖 Pokrywa otwarta – aktywuję oba ekrany niezależnie"
    xrandr --output "\$LAPTOP" --auto --primary --output "\$EXTERNAL" --auto --right-of "\$LAPTOP"
fi
EOF

    sudo chmod +x "$script_path"

    # 4. Reguła ACPI do wywoływania skryptu przy zmianie stanu pokrywy
    local acpi_event_file="/etc/acpi/events/lid-monitor"
    sudo tee "$acpi_event_file" > /dev/null <<EOF
event=button/lid.*
action=su -l $user_name -c "$script_path"
EOF

    echo "🔄 Restartuję acpid, aby załadować nową regułę..."
    sudo systemctl restart acpid

    echo "✅ Gotowe! Ekrany będą przełączane dynamicznie w zależności od stanu pokrywy laptopa."
}
