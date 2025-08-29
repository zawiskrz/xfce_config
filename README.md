# 🧰 Skrypt instalacyjny Openbox dla Debiana 13

Ten skrypt automatyzuje instalację lekkiego środowiska graficznego opartego na **Openboxie** w systemie Debian 13 (Trixie). Zawiera niezbędne pakiety, konfiguratory, motywy oraz komponenty pulpitu.

---

## 📦 Instalowane pakiety


| Pakiet | Przeznaczenie |
|--------|---------------|
| `xorg` | Serwer X11 – podstawa środowiska graficznego |
| `lightdm`, `lightdm-gtk-greeter` | Menedżer logowania i ekran powitalny |
| `openbox`, `obconf` | Menedżer okien i jego konfigurator |
| `lxappearance` | Zmiana motywów GTK, ikon, czcionek |
| `xdg-utils`, `python3-xdg` | Obsługa plików .desktop i integracja aplikacji |
| `upower` | Zarządzanie energią |
| `dmz-cursor-theme` | Motyw kursora myszy |
| `compton` | Kompozytor okien (cienie, przezroczystość) |
| `conky-all` | Monitor systemu na pulpicie |
| `rxvt-unicode` | Lekki terminal z obsługą 256 kolorów |
| `tmux` | Menedżer sesji terminalowych |
| `pkexec` | Uruchamianie aplikacji z uprawnieniami root |
| `tint2` | Lekki panel z zegarem i ikonami |
| `spacefm`, `thunar` | Menedżery plików |
| `udevil` | Automatyczne montowanie urządzeń |
| `geany`, `geany-plugin-spellcheck` | Lekki edytor tekstu z korektą pisowni |
| `qt5ct` | Konfigurator motywów Qt5 |
| `gtk2-engines`, `gtk2-engines-murrine`, `gtk2-engines-pixbuf`, `murrine-themes`, `libgtk2.0-bin` | Silniki i motywy GTK2 |
| `gnome-icon-theme`, `gnome-icon-theme-symbolic`, `gnome-themes-extra` | Ikony i motywy GNOME |
| `mate-themes`, `papirus-icon-theme` | Alternatywne motywy i ikony |
| `at-spi2-core` | Ułatwienia dostępu |
| `dconf-editor`, `dconf-cli` | Edytor ustawień systemowych |
| `network-manager-gnome` | Ikona sieci w trayu |
| `feh` | Ustawianie tapety |
| `jgmenu`, `menu` | Menu aplikacji dla Openboxa |
| `mc` | Midnight Commander – dwupanelowy menedżer plików w terminalu |
| `htop` | Interaktywny monitor procesów w terminalu |



---

## 🛠️ Skrypt `install_packages.sh`

```bash
### 🛠️ Skrypt `install_packages.sh`

#!/bin/bash

LOGFILE="install_log.txt"

echo "🔧 Aktualizacja pakietów..." | tee -a "$LOGFILE"
sudo apt update 2>&1 | tee -a "$LOGFILE"

echo "📦 Instalacja środowiska Openbox..." | tee -a "$LOGFILE"
sudo apt install -y \
xorg lightdm lightdm-gtk-greeter \
openbox obconf lxappearance xdg-utils python3-xdg \
upower dmz-cursor-theme \
compton conky-all \
rxvt-unicode tmux pkexec \
tint2 spacefm udevil \
geany geany-plugin-spellcheck \
qt5ct \
gtk2-engines gtk2-engines-murrine gtk2-engines-pixbuf murrine-themes libgtk2.0-bin \
gnome-icon-theme gnome-icon-theme-symbolic gnome-themes-extra at-spi2-core \
mate-themes papirus-icon-theme \
dconf-editor dconf-cli \
thunar xfce4-terminal network-manager-gnome feh jgmenu menu \
mc htop 2>&1 | tee -a "$LOGFILE"

echo "🔄 Restart LightDM..." | tee -a "$LOGFILE"
sudo systemctl restart lightdm 2>&1 | tee -a "$LOGFILE"

echo "🚀 Uruchamianie komponentów Openbox..." | tee -a "$LOGFILE"
feh --bg-scale /ścieżka/do/tapety.jpg &>> "$LOGFILE"
tint2 &>> "$LOGFILE"
nm-applet &>> "$LOGFILE"
xfce4-terminal &>> "$LOGFILE"
