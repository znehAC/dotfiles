local wezterm = require 'wezterm'

return {
  window_close_confirmation = "NeverPrompt",
  font = wezterm.font_with_fallback({
    { family = "GeistMono Nerd Font Mono", weight = "DemiBold" },
    "FiraMono Nerd Font Mono",
    "JetBrainsMono Nerd Font Mono",
  }),
  font_size = 12,
  adjust_window_size_when_changing_font_size = true,
  window_background_opacity = 0.95,

  colors = {
    foreground = "#2a1f1f",
    background = "#fff1f3",
    cursor_bg = "#ff9bb2",
    cursor_fg = "#2a1f1f",
    cursor_border = "#ff9bb2",
    selection_fg = "#2a1f1f",
    selection_bg = "#ffc7d6",

    ansi = {
      "#d4bcbc", -- black
      "#ff557a", -- red
      "#76d99d", -- green
      "#ff9fa3", -- yellow
      "#78bfff", -- blue
      "#eb80e4", -- magenta
      "#7ee3d8", -- cyan
      "#ffffff", -- white
    },

    brights = {
      "#e7cfcf", -- bright black
      "#ff7b97", -- bright red
      "#96f3b8", -- bright green
      "#ffbfae", -- bright yellow
      "#a4d3ff", -- bright blue
      "#f6a8ef", -- bright magenta
      "#a6f7ee", -- bright cyan
      "#ffffff", -- bright white
    },

    indexed = {
      [16] = "#ffb8c8",
      [17] = "#a8d8ff",
    },

    tab_bar = {
      background = "#ffc8d8",
      active_tab = {
        bg_color = "#a8d8ff",
        fg_color = "#2a1f1f",
        intensity = "Bold",
      },
      inactive_tab = {
        bg_color = "#fff3f7",
        fg_color = "#5a4e4e",
      },
      inactive_tab_hover = {
        bg_color = "#96f3b8",
        fg_color = "#2a1f1f",
        italic = true,
      },
      new_tab = {
        bg_color = "#ffc8d8",
        fg_color = "#2a1f1f",
      },
      new_tab_hover = {
        bg_color = "#b6e3ff",
        fg_color = "#2a1f1f",
        italic = true,
      },
    },
  },

  enable_tab_bar = true,
  enable_scroll_bar = false,
  use_fancy_tab_bar = false,
  tab_max_width = 20,
  window_padding = { left = 8, right = 8, top = 6, bottom = 6 },
  audible_bell = "Disabled",
}
