#!/usr/bin/env bash
set -euo pipefail

SETUP="$HOME/.setup"
DOT="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

echo "🧷 saving current dotfiles state..."

# === wallpaper
if [ -f "$HOME/Pictures/wallpaper.jpg" ]; then
  echo "🖼 backing up wallpaper..."
  mkdir -p "$SETUP/wallpapers"
  cp "$HOME/Pictures/wallpaper.jpg" "$SETUP/wallpapers/wallpaper.jpg"
fi

# === sddm theme
theme_name="ittu-motion"
theme_src="/usr/share/sddm/themes/$theme_name"
theme_dest="$SETUP/sddm-theme"

if [ -d "$theme_src" ]; then
  echo "🎨 backing up sddm theme..."
  sudo rm -rf "$theme_dest"
  sudo cp -r "$theme_src" "$theme_dest"
  sudo chown -R $USER:$USER "$theme_dest"
fi

# === user icon
icon_path="/var/lib/AccountsService/icons/$USER"
if [ -f "$icon_path" ]; then
  echo "👤 backing up user icon..."
  cp "$icon_path" "$SETUP/user-icon.png"
fi

# === package list
echo "📦 saving package list..."
yay -Qqe > "$SETUP/pkglist.txt"

# === dotfiles add
FILES=(
  .zshrc .zshenv .zprofile .bash_profile .gitconfig
  .config/hypr .config/waybar .config/kitty .config/wofi
  .config/mako .config/fastfetch .config/zsh
  .config/input-remapper-2
  .config/gtk-3.0/settings.ini
  .config/gtk-4.0/settings.ini
  .setup/
)

for f in "${FILES[@]}"; do
  [ -e "$HOME/$f" ] && $DOT add "$f"
done

ts=$(date '+%Y-%m-%d %H:%M')
$DOT commit -m "🔒 backup: $ts"

echo "✅ backup complete. run '$DOT push' to sync."
