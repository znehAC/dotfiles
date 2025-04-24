#!/bin/bash
set -euo pipefail

PREFIX="/home/cesar/Games/Heroic/Prefixes/default/Genshin Impact"
echo "🧽 cleaning Genshin prefix: $PREFIX"

if [ ! -d "$PREFIX" ]; then
  echo "❌ prefix not found at: $PREFIX"
  exit 1
fi

export WINEPREFIX="$PREFIX"

# 1. forcibly close stuck wine processes
pkill -f wineserver || true
pkill -f winedevice || true
pkill -f wine || true

# 2. soft reset the prefix
wineboot -u

# 3. optional: nuke DXVK/VKD3D caches (if things keep breaking)
rm -rf "$PREFIX/drive_c/users/$USER/Local Settings/Application Data/DXVK"
rm -rf "$PREFIX/drive_c/users/$USER/AppData/Local/DXVK"
rm -rf "$PREFIX/drive_c/users/$USER/Local Settings/Application Data/vkd3d"

echo "✅ done. prefix cleaned without full wipe."
