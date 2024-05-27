local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Catppuccin Mocha"
config.xcursor_theme = "Adwaita"

config.enable_tab_bar = false

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 16.0
config.line_height = 1.2

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 8

return config
