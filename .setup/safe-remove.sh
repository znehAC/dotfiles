#!/usr/bin/env bash
set -euo pipefail

PKGS=(
  alsa-firmware
  alsa-plugins
  alsa-utils
  lightdm
  lightdm-webkit2-greeter
  lightdm-webkit2-theme-glorious
  nemo
  netctl
  iwd
  inetutils
  iptables-nft
  pokeget
  welcome
  eos-apps-info
  eos-quickstart
  eos-hooks
  eos-log-tool
  eos-dracut
  eos-rankmirrors
  eos-packagelist
  s-nail
  xterm
  usb_modeswitch
  smartmontools
  lsscsi
  cage
  xorg-xdpyinfo
  xf86-input-libinput
  b43-fwcutter
  haveged
  input-remapper-git
)

echo "🚮 trying to remove each package individually..."
for pkg in "${PKGS[@]}"; do
  echo -n "🗑 removing $pkg... "
  if sudo pacman -Rns --noconfirm "$pkg" &>/dev/null; then
    echo "✅ removed"
  else
    echo "❌ skipped (dependency)"
  fi
done

echo "🧹 done. consider running 'sudo pacman -Rns $(pacman -Qdtq)' to clean orphans."
