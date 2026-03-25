local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.color_scheme = 'Atelierdune (light) (terminal.sexy)'
config.font = wezterm.font('JetBrains Mono', { weight = 'Medium' })
config.font_size = 14
config.window_background_opacity = 0.95
--config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "TITLE"

-- Use zsh by default
config.default_prog = { "/usr/bin/zsh", "-l" }

return config
