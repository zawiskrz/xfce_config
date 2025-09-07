#!/bin/bash

configure_lid_poweroff() {
    echo "🔧 Konfiguruję zachowanie ekranów i pokrywy laptopa..."

    # 1. Konfiguracja systemd-logind
    local config_file="/etc/systemd/logind.conf"
    local backup_file="/etc/systemd/logind.conf.bak"

    echo "📁 Tworzę kopię zapasową: $backup_file"
    sudo cp "$config_file" "$backup_file"

    echo "📝 Ustawiam zachowanie pokrywy w zależności od zasilania"
    sudo sed -i '/^HandleLidSwitch=/d' "$config_file"
    sudo sed -i '/^HandleLidSwitchExternalPower=/d' "$config_file"
    echo "HandleLidSwitch=poweroff" | sudo tee -a "$config_file" > /dev/null
    echo "HandleLidSwitchExternalPower=ignore" | sudo tee -a "$config_file" > /dev/null

    echo "🔄 Restartuję systemd-logind..."
    sudo systemctl restart systemd-logind

    # 2. Instalacja acpid
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
    echo "🔒 Pokrywa zamknięta – ekran laptopa wyłączony, zewnętrzny aktywny"
    xrandr --output "\$LAPTOP" --off --output "\$EXTERNAL" --auto --primary
else
    echo "📖 Pokrywa otwarta – oba ekrany aktywne, zewnętrzny jako główny"
    xrandr --output "\$EXTERNAL" --auto --primary --output "\$LAPTOP" --auto --left-of "\$EXTERNAL"
fi
EOF

    sudo chmod +x "$script_path"

    # 4. Reguła ACPI – dynamiczne przełączanie ekranów
    local acpi_event_file="/etc/acpi/events/lid-monitor"
    sudo tee "$acpi_event_file" > /dev/null <<EOF
event=button/lid.*
action=su -l $user_name -c "$script_path"
EOF

    sudo systemctl restart acpid

    # 5. Autostart w XFCE – uruchomienie skryptu po zalogowaniu
    local autostart_dir="/home/$user_name/.config/autostart"
    local desktop_file="$autostart_dir/lid-monitor.desktop"
    mkdir -p "$autostart_dir"

    sudo tee "$desktop_file" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=$script_path
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Monitor Lid Switch
Comment=Przełącza ekrany po starcie sesji graficznej
EOF

    sudo chown "$user_name:$user_name" "$desktop_file"

    echo "✅ Gotowe! System wyłączy się na baterii po zamknięciu pokrywy, a na zasilaniu zewnętrznym przełączy ekrany zgodnie z konfiguracją."
}