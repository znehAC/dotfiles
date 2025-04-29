# start keyring daemon if not already running
if ! pgrep -fu "$USER" gnome-keyring-daemon > /dev/null; then
  eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
  export SSH_AUTH_SOCK
fi

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland

# fix for electron apps
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export OZONE_PLATFORM=wayland

# nvidia-specific cope :'C
export WLR_NO_HARDWARE_CURSORS=1
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm

# preferred apps
export EDITOR="micro"
export VISUAL="$EDITOR"
export BROWSER="firefox"
export TERMINAL="kitty"
export FILE_MANAGER="nautilus"
export VIDEO_PLAYER="mpv"
export IMAGE_VIEWER="imv"

# misc
export MOZ_ENABLE_WAYLAND=1 # firefox
export MOZ_WEBRENDER=1

export GDK_BACKEND=wayland
export HYPRSHOT_DIR="$HOME/Pictures/Screenshots"
export XCURSOR_THEME=catppuccin-latte-light-cursors
export XCURSOR_SIZE=24

export PATH="$HOME/.local/bin:$PATH"
