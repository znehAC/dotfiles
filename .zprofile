# start keyring daemon if not already running
# if [ -n "$DESKTOP_SESSION" ]; then
#   for env_var in $(gnome-keyring-daemon --start); do
#     export $env_var
#   done
# fi


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
