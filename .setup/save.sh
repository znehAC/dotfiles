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

# === fonts
font_src="$HOME/.local/share/fonts"
font_dst="$SETUP/fonts"
if [ -d "$font_src" ]; then
  echo "🔤 backing up fonts..."
  mkdir -p "$font_dst"
  cp -r "$font_src/"* "$font_dst/"
fi

# === user icon
icon_path="/var/lib/AccountsService/icons/$USER"
if [ -f "$icon_path" ]; then
  echo "👤 backing up user icon..."
  mime=$(file --mime-type -b "$icon_path")
    case "$mime" in
      image/png) ext="png" ;;
      image/gif) ext="gif" ;;
      image/webp) ext="webp" ;;
      image/jpeg) ext="jpg" ;;
      *) ext="img" ;;
    esac
  cp "$icon_path" "$SETUP/user-icon.$ext"
fi

# === save firefox .desktop
desktop_src="/usr/share/applications/firefox.desktop"
desktop_dst="$SETUP/firefox/firefox.desktop"
if [ -f "$desktop_src" ]; then
  echo "🖇 backing up firefox.desktop..."
  mkdir -p "$SETUP/firefox"
  cp "$desktop_src" "$desktop_dst"
fi


# === save firefox user.js
profile=$(find ~/.mozilla/firefox -type d -name "*.default*" | head -1)
if [ -n "$profile" ] && [ -f "$profile/user.js" ]; then
  echo "🦊 backing up user.js..."
  cp "$profile/user.js" "$SETUP/firefox/user.js"
fi


# === package list
echo "📦 saving package list..."
yay -Qqe > "$SETUP/pkglist.txt"

# === dotfiles add
FILES=(
  .zshrc .zshenv .zprofile .bash_profile .gitconfig
  .config/hypr .config/waybar .config/kitty .config/wofi
  .config/mako .config/fastfetch .config/zsh
  .config/gtk-3.0/settings.ini
  .config/gtk-4.0/settings.ini
  .setup/
  .local/bin/*.sh
)

for f in "${FILES[@]}"; do
  if [ -e "$HOME/$f" ]; then
    echo "➕ staging $f..."
    $DOT add "$f"
  fi
done


ts=$(date '+%Y-%m-%d %H:%M')
if ! $DOT diff --cached --quiet; then
  $DOT commit -m "🔒 backup: $ts" >/dev/null
  echo "✅ committed changes at $ts"
else
  echo "⚠️  nothing new to commit"
fi

echo "✅ backup complete. run '$DOT push' to sync."
