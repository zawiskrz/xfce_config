#!/bin/bash

configure_cuda() {
  echo "⚡ Instalacja CUDA Toolkit..." | tee -a "$LOGFILE"
  wget "$CUDA_KEYRING_URL" -O cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
  sudo dpkg -i cuda-keyring.deb 2>&1 | tee -a "$LOGFILE"
  sudo apt update
  sudo apt install -y cuda 2>&1 | tee -a "$LOGFILE"
  echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
}