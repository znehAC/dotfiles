# start keyring daemon if not already running
if ! pgrep -u "$USER" gnome-keyring-daemon > /dev/null; then
  eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets,pkcs11,ssh)
  export SSH_AUTH_SOCK
fi
