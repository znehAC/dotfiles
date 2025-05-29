local wezterm = require 'wezterm'

return {
    window_close_confirmation = "NeverPrompt",
    font = wezterm.font_with_fallback({
        { family = "GeistMono Nerd Font Mono", weight = "DemiBold" }, -- no weight set
        "FiraMono Nerd Font Mono",
        "JetBrainsMono Nerd Font Mono",
    }),
    font_size = 12,
    adjust_window_size_when_changing_font_size = true,
    window_background_opacity = 0.95,
    colors = {
        foreground = "#332c2c",
        background = "#ffeeef",
        cursor_bg = "#ffc6c7",
        cursor_fg = "#332c2c",
        cursor_border = "#ffc6c7",
        selection_fg = "#ffffff",
        selection_bg = "#ffc6c7",
        ansi = {
            "#d7c0c0", "#ff6b81", "#a8dadc", "#e0a84c",
            "#5686f0", "#f2a2e8", "#2dd6c1", "#e3d5ca",
        },
        brights = {
            "#e7d0d0", "#ff8fa3", "#b5e8e0", "#ffe0b2",
            "#aec8ff", "#fbc2eb", "#c7f9cc", "#f5ebe0",
        },
        indexed = {
            [16] = "#ffd6d9",
            [17] = "#ffc6c7",
        },
    },
    enable_tab_bar = false,
    enable_scroll_bar = false,
    window_padding = {
        left = 8, right = 8, top = 6, bottom = 6,
    },
    audible_bell = "Disabled",
}
