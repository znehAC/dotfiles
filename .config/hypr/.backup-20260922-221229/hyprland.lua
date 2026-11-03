-- ============================================================
-- HYPRLAND 0.56.2 — config em LUA (migrado do niri + do antigo hyprland.conf)
-- envs ficam em ~/.config/environment.d/10-session.conf (sessão systemd)
--
-- O formato antigo (hyprlang, .conf) será REMOVIDO no Hyprland 0.57.
-- Docs: https://wiki.hypr.land/0.56.0/Configuring/Start/
-- ============================================================

-- Equivalente aos antigos `source = ...`
require("windowrules")
require("autostart")
require("popups")

local mainMod   = "SUPER"
local rofiTheme = "/home/cesar/.config/rofi/themes/pastel-candy.rasi"

-- ============================================================
-- MONITOR
-- ============================================================

-- vrr 3 = VRR só em fullscreen com conteúdo video/game (niri: on-demand)
hl.monitor({
    output   = "DP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
    vrr      = 3,
})

-- ============================================================
-- GENERAL + APPEARANCE
-- ============================================================

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 4,
        border_size = 4,
        col = {
            active_border   = "rgb(2a9ff5)",
            inactive_border = "rgb(505050)",
        },
        layout = "dwindle",
    },

    cursor = {
        no_hardware_cursors = true,
    },

    decoration = {
        rounding         = 12,
        active_opacity   = 0.99,
        inactive_opacity = 0.99,
        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        -- transparente para o swaybg (systemd) aparecer por trás
        background_color        = "rgba(0,0,0,0)",
        middle_click_paste      = false,
    },

    render = {
        direct_scanout = 2,
    },

    input = {
        kb_layout     = "br",
        kb_variant    = "abnt2",
        kb_options    = "caps:none",
        repeat_delay  = 600,
        repeat_rate   = 25,
        follow_mouse  = 1,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "default" })

-- ============================================================
-- MOUSE
-- ============================================================

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================
-- WINDOW MANAGEMENT
-- ============================================================

hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q",     hl.dsp.window.close())
hl.bind(mainMod .. " + F",     hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- niri fullscreen-window
hl.bind(mainMod .. " + R",     hl.dsp.layout("togglesplit"))                      -- ~ niri switch-preset-column-width
hl.bind(mainMod .. " + M",     hl.dsp.window.fullscreen({ mode = "maximized" }))  -- ~ niri maximize-column
hl.bind(mainMod .. " + C",     hl.dsp.layout("splitratio 0.5"))                   -- ~ niri center-column

hl.bind(mainMod .. " + H",         hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L",         hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",         hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",         hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- ============================================================
-- LAUNCHERS + APPS
-- ============================================================

hl.bind(mainMod .. " + T",       hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + RETURN",  hl.dsp.exec_cmd("rofi -show drun -theme " .. rofiTheme))
hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))

-- ============================================================
-- MEDIA KEYS
-- ============================================================

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))

-- ============================================================
-- SCREENSHOTS
-- ============================================================

hl.bind("Print",                   hl.dsp.exec_cmd("/home/cesar/.local/bin/screenshot"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/cesar/.local/bin/screenshot"))

-- ============================================================
-- WORKSPACES
-- ============================================================

for i = 1, 10 do
    local key = i % 10 -- 10 vira a tecla 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ciclo de workspaces (niri focus-workspace-up/down)
hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "-1" }))

-- alt-tab: próximo/anterior workspace ocupado
hl.bind("ALT + TAB",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- ============================================================
-- SESSION
-- ============================================================

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit()) -- encerra a sessão (uwsm derruba tudo)
