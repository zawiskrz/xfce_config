#!/bin/bash

configure_emacs() {
    echo "🔧 Instalacja Emacs i narzędzi..."

  # Aktualizacja systemu
  sudo apt update && sudo apt upgrade -y

  # Instalacja Emacs (GUI + terminal)
  sudo apt install -y emacs git curl

  # Instalacja zależności do kompilacji pakietów (np. dla lsp-mode)
  sudo apt install -y build-essential cmake python3-pip nodejs npm ripgrep

  # Instalacja narzędzi programistycznych
  sudo apt install -y clang-format shellcheck

  # Tworzenie katalogu konfiguracyjnego
  mkdir -p ~/.emacs.d

  # Tworzenie pliku init.el z pełną konfiguracją
  cat << 'EOF' > ~/.emacs.d/init.el
;; -------------------------------
;; Emacs pełna konfiguracja
;; -------------------------------

;; Włącz package.el i dodaj MELPA
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Automatyczna instalacja use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; 🔧 Interfejs
(use-package which-key
  :config (which-key-mode))

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

(use-package consult)

(use-package avy
  :bind ("C-:" . avy-goto-char))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; 💻 Programowanie
(use-package lsp-mode
  :hook ((python-mode . lsp)
         (c-mode . lsp)
         (rust-mode . lsp))
  :commands lsp)

(use-package company
  :hook (after-init . global-company-mode))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package projectile
  :init (projectile-mode +1)
  :bind-keymap ("C-c p" . projectile-command-map))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package dumb-jump
  :config (setq dumb-jump-mode t)
  :bind (("M-g o" . dumb-jump-go-other-window)
         ("M-g j" . dumb-jump-go)
         ("M-g b" . dumb-jump-back)))

;; 📄 Pisanie i dokumentacja
(use-package markdown-mode
  :mode "\\.md\\'")

(use-package org
  :config
  (setq org-log-done 'time
        org-startup-indented t))

(use-package org-super-agenda
  :config (org-super-agenda-mode))

(use-package org-ql)

(use-package nov
  :mode "\\.epub\\'")

(use-package darkroom
  :hook (markdown-mode . darkroom-mode))

;; 🌐 Internet i dokumentacja
(use-package eww) ;; Wbudowana przeglądarka

(use-package devdocs
  :bind ("C-c d" . devdocs-lookup))

(use-package restclient)

(use-package ob-restclient
  :after org)

;; 🧠 Usprawnienia edycji (bez Vima)
(use-package multiple-cursors
  :bind (("C-c m c" . mc/edit-lines)
         ("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)))

;; 🧹 Dodatki
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode t)
EOF

  echo "✅ Instalacja zakończona. Uruchom Emacs, by rozpocząć pracę!"

}