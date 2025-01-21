-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.color_scheme = "Batman"
config.color_scheme = "Catppuccin Mocha"
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_decorations = "RESIZE"
config.line_height = 1.2
config.enable_tab_bar = true
config.window_background_opacity = 0.95
-- config.win32_system_backdrop = "Acrylic" INFO: Not sure if i like this effect or not.

-- config.background = {
-- 	{
-- 		source = { File = "/path/to/image.png" },
-- 		width = "100%",
-- 		height = "100%",
-- 		opacity = 0.1,
-- 		attachment = { Parallax = 0.1 },
-- 	},
-- }
local act = wezterm.action
config.keys = {
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("DefaultDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
}

-- Retrieve the default WSL domains
local wsl_domains = wezterm.default_wsl_domains()

-- Set the WSL domains
config.wsl_domains = wsl_domains

-- Set the default domain to your preferred WSL distribution
-- Replace 'WSL:Ubuntu' with the actual name of your distribution
config.default_domain = "WSL:Ubuntu"

return config
