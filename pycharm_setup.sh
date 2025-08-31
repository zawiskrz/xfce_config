#!/bin/bash

configure_pycharm(){
  echo "🐍 Instalacja PyCharma..." | tee -a "$LOGFILE"
  wget https://download.jetbrains.com/python/pycharm-community-${PYCHARM_VERSION}.tar.gz -O pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  tar -xzf pycharm.tar.gz 2>&1 | tee -a "$LOGFILE"
  sudo mv pycharm-community-${PYCHARM_VERSION} "$PYCHARM_DIR"
  cat <<EOF | sudo tee /usr/share/applications/pycharm.desktop
[Desktop Entry]
Name=PyCharm Community
Exec=${PYCHARM_DIR}/bin/pycharm
Icon=${PYCHARM_DIR}/bin/pycharm.png
Type=Application
Categories=Development;IDE;
EOF

}