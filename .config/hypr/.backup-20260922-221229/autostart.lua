-- ============================================================
-- AUTOSTART — só apps do WM aqui.
-- Equivalente aos antigos `exec-once = ...` (rodam no evento hyprland.start).
-- O resto roda por serviços systemd do usuário:
--   swaync, hypridle, hyprpolkitagent, xembedsniproxy
--   openrgb-server + openrgb-apply (start_led.sh)
--   rclone-gdrive, ironbar, swaybg, cliphist, gammastep, ...
-- ============================================================

hl.on("hyprland.start", function()
    -- lockscreen na entrada (autologin): se falhar, derruba a sessão
    hl.exec_cmd("hyprlock || hyprctl dispatch 'hl.dsp.exit()'")

    -- integração com o celular (dbus-activated)
    hl.exec_cmd("kdeconnectd")

    -- apps (posicionados pelas window rules)
    hl.exec_cmd("zen-browser")
    hl.exec_cmd("ghostty --class=com.mitchellh.ghostty.btop -e btop")
    hl.exec_cmd("spotify")
    hl.exec_cmd("gtk-launch vesktop")
    hl.exec_cmd("steam -silent")
end)
