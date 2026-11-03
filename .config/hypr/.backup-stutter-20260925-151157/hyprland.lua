require("windowrules")
require("autostart")
require("popups")

local mainMod   = "SUPER"

-- ============================================================
-- MONITOR
-- ============================================================

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
    gaps_in     = 2,
    gaps_out    = 8,
    border_size = 0,
    -- col = {
    --     active_border   = "rgb(2a9ff5)",
    --     inactive_border = "rgba(2a9ff566)",
    -- },
    layout      = "dwindle",
  },

  cursor = {
    no_hardware_cursors = true,
  },

  decoration = {
    rounding         = 20,
    active_opacity   = 0.99,
    inactive_opacity = 0.99,
    shadow           = {
      enabled      = true,
      range        = 22,
      render_power = 3,
      offset       = { 0, 7 },
      color        = "rgba(1a1a1a59)",
    },
    blur             = {
      enabled  = true,
      size     = 3,
      passes   = 1,
      vibrancy = 0.1696,
    },
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
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
    touchpad      = {
      natural_scroll = true,
      tap_to_click   = true,
    },
  },

  animations = {
    enabled = true,
  },
})

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "default" })

-- Troca de workspace: fade rápido de entrada/saída, em vez do slide lento.
-- Sem uma leaf explícita, workspaces herda a `global` (speed 8, sem estilo),
-- que é exatamente o slide que incomodava. speed é a DURAÇÃO (menor = mais
-- rápido): 8 -> 2. O style "fade" é o mesmo que o default do Hyprland usa.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 2, bezier = "default", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, bezier = "default", style = "fade" })

-- ============================================================
-- BUBBLE CANDY PANELS
-- ============================================================
-- The dashboard and the control centre are not popups that appear: they are
-- blobs that grow out of the bar, and their geometry animates inside a
-- fixed-size surface. Hyprland's default layersIn/layersOut fade cross-fades
-- the whole surface as it maps/unmaps, which reads as the panel "fading in"
-- over the top of the growth and destroys the illusion. Measured on a glyph
-- pixel inside the dashboard: 209 -> 44 over ~500 ms with the default, and it
-- snaps straight to 44 with no_anim. The shell animates these itself.
-- Every BLOB panel, not just the two that had been measured. The match is an RE2
-- regex over the whole namespace (Hyprland's LayerRule does a FullMatch), so one rule
-- covers the dashboard, the control centre and the launcher — and the launcher was the
-- one that was missing: it is the blob that detaches, and the fade therefore landed on
-- its map/unmap, which read as the blob going transparent while it closed and the
-- shell's ripple showing through it.
hl.layer_rule({ match = { namespace = "bubble-candy-(dashboard|controlcenter|launcher|panel)" }, no_anim = true })

-- ============================================================
-- MOUSE
-- ============================================================

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ============================================================
-- WINDOW MANAGEMENT
-- ============================================================

hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- niri fullscreen-window
hl.bind(mainMod .. " + R", hl.dsp.layout("togglesplit"))                      -- ~ niri switch-preset-column-width
hl.bind(mainMod .. " + C", hl.dsp.layout("splitratio 0.5"))                   -- ~ niri center-column

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- ============================================================
-- LAUNCHERS + APPS
-- ============================================================

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty"))
-- The app menu is Bubble Candy's own launcher (modules/launcher/), asked for over
-- Quickshell's IPC. Rofi is retired: a second process that draws a second material
-- was never going to match the shell it opens over.
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("qs ipc call shell toggleLauncher"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("hyprlock"))

-- ============================================================
-- MEDIA KEYS
-- ============================================================

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- ============================================================
-- SCREENSHOTS
-- ============================================================

hl.bind("Print", hl.dsp.exec_cmd("/home/cesar/.local/bin/screenshot"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("/home/cesar/.local/bin/screenshot"))

-- ============================================================
-- WORKSPACES
-- ============================================================

for i = 1, 10 do
  local key = i % 10 -- 10 vira a tecla 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ciclo de workspaces (niri focus-workspace-up/down)
hl.bind(mainMod .. " + U", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + I", hl.dsp.focus({ workspace = "-1" }))

-- alt-tab: próximo/anterior workspace ocupado
hl.bind("ALT + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- ============================================================
-- SESSION
-- ============================================================

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit()) -- encerra a sessão (uwsm derruba tudo)
