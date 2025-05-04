# start keyring daemon if not already running
if ! pgrep -fu "$USER" gnome-keyring-daemon > /dev/null; then
  eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
  export SSH_AUTH_SOCK
fi

# preferred apps
export EDITOR="micro"
export VISUAL="$EDITOR"
export BROWSER="firefox"
export TERMINAL="kitty"
export FILE_MANAGER="nautilus"
export VIDEO_PLAYER="mpv"
export IMAGE_VIEWER="imv"

export HYPRSHOT_DIR="$HOME/Pictures/Screenshots"
export PATH="$HOME/.local/bin:$PATH"
