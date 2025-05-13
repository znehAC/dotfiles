#!/bin/bash

exec >> /tmp/startup.log 2>&1
echo "[start] running wrapper"

# wait for wayland socket to be ready
for i in {1..20}; do
  if [ -S /run/user/1000/wayland-0 ]; then
    echo "[start] wayland detected"
    break
  fi
  echo "[wait] waiting for wayland..."
  sleep 0.2
done

# launch hyprlock in background
echo "[start] launching hyprlock"
hyprlock &

sleep 0.3
echo "[start] launching Hyprland"
exec Hyprland
