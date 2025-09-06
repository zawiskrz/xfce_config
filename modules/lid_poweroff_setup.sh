#!/bin/bash

configure_lid_poweroff() {
    local config_file="/etc/systemd/logind.conf"
    local backup_file="/etc/systemd/logind.conf.bak"

    echo "🔧 Tworzę kopię zapasową pliku konfiguracyjnego..."
    sudo cp "$config_file" "$backup_file"

    echo "📝 Modyfikuję ustawienia w $config_file..."

    # Dodaj lub nadpisz odpowiednie linie
    sudo sed -i '/^HandleLidSwitch=/d' "$config_file"
    sudo sed -i '/^HandleLidSwitchExternalPower=/d' "$config_file"

    echo "HandleLidSwitch=poweroff" | sudo tee -a "$config_file" > /dev/null
    echo "HandleLidSwitchExternalPower=poweroff" | sudo tee -a "$config_file" > /dev/null


    echo "🔄 Restartuję usługę systemd-logind..."
    sudo systemctl restart systemd-logind

    echo "✅ Gotowe! Zamknięcie pokrywy będzie teraz wyłączać system."
}
