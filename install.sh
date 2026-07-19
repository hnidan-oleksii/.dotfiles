#!/usr/bin/env bash
# Stow my config packages into $HOME. --packages also installs dnf/flatpak apps.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

PACKAGES=(nvim lf tmux bash bin alacritty git mangohud xorg dwm ssh tauon wallpapers)

STOW_FLAGS=(-v)
INSTALL_PACKAGES=0
for arg in "$@"; do
  case "$arg" in
    --adopt)    STOW_FLAGS+=(--adopt) ;;
    --packages) INSTALL_PACKAGES=1 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

command -v stow >/dev/null || sudo dnf install -y stow

if [ "$INSTALL_PACKAGES" -eq 1 ]; then
  sudo dnf install -y $(grep -vE '^\s*#' packages/dnf.txt | tr '\n' ' ') || true
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  xargs -a packages/flatpak.txt -r flatpak install -y flathub || true
fi

stow "${STOW_FLAGS[@]}" -t "$HOME" "${PACKAGES[@]}"
stow "${STOW_FLAGS[@]}" --no-folding -t "$HOME" fcitx5   # no-folding keeps fcitx5 cache out of the repo
