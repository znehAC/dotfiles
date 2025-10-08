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
        tab_bar = {
            background = "#ffd6e0", -- soft pink strip

            active_tab = {
                bg_color = "#a8d8ff", -- baby blue for the selected tab
                fg_color = "#332c2c",
                intensity = "Bold",
            },

            inactive_tab = {
                bg_color = "#ffeef7", -- lighter pink
                fg_color = "#665c5c",
            },

            inactive_tab_hover = {
                bg_color = "#d6f5ff", -- pale blue hover
                fg_color = "#332c2c",
                italic = true,
            },

            new_tab = {
                bg_color = "#a8d8ff", -- same baby blue as active tab
                fg_color = "#332c2c",
            },

            new_tab_hover = {
                bg_color = "#ccecff", -- lighter blue hover
                fg_color = "#332c2c",
                italic = true,
            },
        },
    },
    enable_tab_bar = true,
    enable_scroll_bar = false,
    use_fancy_tab_bar = false,
    tab_max_width = 20,
    window_padding = {
        left = 8, right = 8, top = 6, bottom = 6,
    },
    audible_bell = "Disabled",
}
