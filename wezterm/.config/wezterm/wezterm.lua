local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- config.color_scheme = "Catppuccin Mocha"
config.colors = require("cyberdream")
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_decorations = "RESIZE"
config.line_height = 1.2
config.enable_tab_bar = true
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

local act = wezterm.action
config.keys = {
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("DefaultDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
}

-- Only set WSL-specific configuration on Windows
if wezterm.target_triple:find("windows") then
	local wsl_domains = wezterm.default_wsl_domains()
	config.wsl_domains = wsl_domains
	config.default_domain = "WSL:Ubuntu"
end

return config
