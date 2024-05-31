local wezterm = require("wezterm")

local config = wezterm.config_builder()

local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function get_color_scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "nightfox"
	else
		return "dayfox"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = get_color_scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

config.color_scheme = get_color_scheme_for_appearance(get_appearance())
config.xcursor_theme = "Adwaita"

config.enable_tab_bar = false

config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 16.0
config.line_height = 1.2

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.75
config.macos_window_background_blur = 8

return config
