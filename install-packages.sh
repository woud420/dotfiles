#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$SCRIPT_DIR/packages"

if command -v brew >/dev/null 2>&1; then
  PKG_FILE="$PACKAGE_DIR/brew.txt"
  PM="brew"
elif command -v pacman >/dev/null 2>&1; then
  PKG_FILE="$PACKAGE_DIR/pacman.txt"
  PM="pacman"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_FILE="$PACKAGE_DIR/apt.txt"
  PM="apt"
else
  echo "No supported package manager found" >&2
  exit 1
fi

if [[ ! -f "$PKG_FILE" ]]; then
  echo "Package list $PKG_FILE not found" >&2
  exit 1
fi

mapfile -t PACKAGES < "$PKG_FILE"

install_brew() {
  for pkg in "${PACKAGES[@]}"; do
    brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg"
  done
}

install_apt() {
  sudo apt-get update
  for pkg in "${PACKAGES[@]}"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo apt-get install -y "$pkg"
    else
      echo "[apt] package not found: $pkg" >&2
    fi
  done
}

install_pacman() {
  sudo pacman -Sy
  for pkg in "${PACKAGES[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      sudo pacman -S --needed "$pkg"
    else
      echo "[pacman] package not found: $pkg" >&2
    fi
  done
}

case "$PM" in
  brew)
    install_brew
    ;;
  pacman)
    install_pacman
    ;;
  apt)
    install_apt
    ;;
esac
