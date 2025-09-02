#!/bin/bash

configure_rstudio(){
  echo "🧪 Instalacja R 4.4.0 i RStudio..." | tee -a "$LOGFILE"

  # Wymuszenie klasycznego GPG zamiast Sequoia (apt.conf.d)
  echo 'Binary::apt::Acquire::GPGV::Options "--use-legacy-gpg";' | \
    sudo tee /etc/apt/apt.conf.d/99legacy-gpg > /dev/null

  # Instalacja narzędzi do obsługi kluczy
  sudo apt install -y dirmngr gnupg ca-certificates | tee -a "$LOGFILE"

  # Dodanie klucza CRAN ręcznie
  gpg --keyserver keyserver.ubuntu.com --recv-keys 7BA040A510E4E66ED3743EC1B8F25A8A73EACF41
  gpg --export 7BA040A510E4E66ED3743EC1B8F25A8A73EACF41 | \
    sudo tee /etc/apt/trusted.gpg.d/cran.gpg > /dev/null

  # Dodanie repozytorium CRAN dla Debiana 13
  echo "deb https://cloud.r-project.org/bin/linux/debian trixie-cran40/" | \
    sudo tee /etc/apt/sources.list.d/cran.list > /dev/null

  # Aktualizacja listy pakietów
  sudo apt update | tee -a "$LOGFILE"

  # Instalacja R 4.4.0 i zależności
  sudo apt install -y r-base r-base-dev gdebi-core libclang-dev libssl-dev | tee -a "$LOGFILE"

  # Pobranie i instalacja RStudio
  wget "$RSTUDIO_URL" -O rstudio.deb | tee -a "$LOGFILE"
  sudo gdebi -n rstudio.deb | tee -a "$LOGFILE"

      # 🧹 Sprzątanie
  echo "🧹 Usuwanie pobranego pliku .deb..." | tee -a "$LOGFILE"
  rm -f rstudio.deb

  # Weryfikacja wersji R
  echo "📋 Zainstalowana wersja R:" | tee -a "$LOGFILE"
  R --version | tee -a "$LOGFILE"
}