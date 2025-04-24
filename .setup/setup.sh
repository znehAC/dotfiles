#!/usr/bin/env bash
set -euo pipefail

SETUP="$HOME/.setup"
echo "🔧 restoring dotfiles setup..."

### === zsh themes ===
[ ! -d "$HOME/.zsh/pure" ] && git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
[ ! -d "$HOME/.config/zsh/catppuccin-syntax" ] && git clone https://github.com/catppuccin/zsh-syntax-highlighting "$HOME/.config/zsh/catppuccin-syntax"

### === package install ===
if command -v yay &>/dev/null && [ -f "$SETUP/pkglist.txt" ]; then
  echo "📦 installing packages from pkglist.txt..."
  yay -S --needed --noconfirm $(< "$SETUP/pkglist.txt")
fi

### === wallpaper restore ===
if [ -f "$SETUP/wallpapers/wallpaper.jpg" ]; then
  mkdir -p "$HOME/Pictures"
  cp "$SETUP/wallpapers/wallpaper.jpg" "$HOME/Pictures/wallpaper.jpg"
fi

### === install Catppuccin GTK theme (Latte + Pink) ===
echo "🎨 installing Catppuccin GTK theme (latte + pink)..."
yay -S --needed catppuccin-gtk-theme-latte --noconfirm

### === install Colloid icon theme (Catppuccin + Pink) ===
echo "🎨 installing Colloid icon theme (catppuccin + pink)..."
ICON_DIR="$HOME/.local/share/icons"
THEME_DIR="$HOME/.setup/_colloid-icon-theme"

if [ ! -d "$THEME_DIR" ]; then
  git clone --depth=1 git@github.com:vinceliuice/Colloid-icon-theme.git "$THEME_DIR"
fi

bash "$THEME_DIR/install.sh" \
  --dest "$ICON_DIR" \
  --name "Colloid-Pink-Catppuccin" \
  --scheme catppuccin \
  --theme pink \
  --notint

echo "🧼 cleaning up Colloid git repo..."
rm -rf "$THEME_DIR"

### === fonts ===
if [ -d "$SETUP/fonts" ]; then
  mkdir -p "$HOME/.local/share/fonts"
  cp -r "$SETUP/fonts/"* "$HOME/.local/share/fonts/"
  fc-cache -f
fi

### === apply GTK theme + icon theme + font ===
echo "⚙️ applying GTK theme and font..."
GTK_THEME="catppuccin-latte-pink-standard+default"
ICON_THEME="Colloid-Pink-Catppuccin"
SYSTEM_FONT="SF Pro Display 11"

mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=$SYSTEM_FONT
EOF

cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini


# === restore firefox .desktop
desktop_dst="$SETUP/firefox/firefox.desktop"
if [ -f "$desktop_dst" ]; then
  echo "🖇 restoring firefox.desktop..."
  mkdir -p "$HOME/.local/share/applications"
  cp "$desktop_dst" "$HOME/.local/share/applications/firefox.desktop"
fi

# === restore firefox user.js
profile=$(find ~/.mozilla/firefox -type d -name "*.default*" | head -1)
if [ -n "$profile" ] && [ -f "$SETUP/firefox/user.js" ]; then
  echo "🦊 restoring user.js to $profile..."
  cp "$SETUP/firefox/user.js" "$profile/user.js"
fi

### === sddm theme ===
theme_name="ittu-motion"
theme_target="/usr/share/sddm/themes/$theme_name"
if [ -d "$SETUP/sddm-theme" ]; then
  echo "🎨 installing SDDM theme: $theme_name..."
  sudo mkdir -p "$theme_target"
  sudo cp -r "$SETUP/sddm-theme/"* "$theme_target/"
  sudo chown -R root:root "$theme_target"
fi

sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=$theme_name" | sudo tee /etc/sddm.conf.d/20-theme.conf > /dev/null

### === sddm wallpaper ===
if [ -f "$SETUP/wallpapers/wallpaper.jpg" ]; then
  sudo cp "$SETUP/wallpapers/wallpaper.jpg" "$theme_target/backgrounds/wallpaper.jpg"
fi

### === user icon ===
icon_file=$(find "$SETUP" -name "user-icon.*" | head -1)
if [ -n "$icon_file" ]; then
  echo "👤 restoring user icon..."
  sudo mkdir -p /var/lib/AccountsService/icons/
  sudo cp "$icon_file" "/var/lib/AccountsService/icons/$USER"

  sudo mkdir -p /var/lib/AccountsService/users/
  echo -e "[User]\nIcon=/var/lib/AccountsService/icons/$USER" | sudo tee /var/lib/AccountsService/users/$USER > /dev/null
fi


echo "✅ setup complete."
