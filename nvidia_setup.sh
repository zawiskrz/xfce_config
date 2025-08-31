#!/bin/bash

configure_nvidia(){
  echo "🎮 Instalacja sterowników NVIDIA..." | tee -a "$LOGFILE"
  sudo apt install -y nvidia-detect 2>&1 | tee -a "$LOGFILE"
  if nvidia-detect | grep -q "recommended"; then
    sudo apt install -y nvidia-driver nvidia-settings 2>&1 | tee -a "$LOGFILE"
  fi
}