local wezterm = require("wezterm")
local config = {}
config.color_scheme = "Batman"
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 14
config.line_height = 1.2
config.background = {
	{
		source = { File = "/path/to/image.png" },
		width = "100%",
		height = "100%",
		opacity = 0.1,
		attachment = { Parallax = 0.1 },
	},
}
local act = wezterm.action
config.keys = {
	{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("DefaultDomain") },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
}
return config
