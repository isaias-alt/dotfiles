local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "Atom One Darker"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 16.0
config.window_background_opacity = 0.9
-- Without this, apps that paint an explicit cell background (nvim, herdr,
-- prompt segments) render fully opaque regardless of window_background_opacity
-- above. This value compounds with window_background_opacity (effective
-- opacity for a full cell-background paint is text + (1-text)*window), so
-- anything above 0 makes nvim's pane visibly more opaque than the rest of
-- the terminal. At 0.0 nvim matches exactly, but every app-painted
-- background (herdr's selected-tab highlight, prompt segment backgrounds)
-- also vanishes, leaving their foreground text floating on raw transparency
-- with harsher contrast. Kept low (not 0) as a middle ground: nvim's
-- mismatch stays faint, and other apps keep a sliver of background.
config.text_background_opacity = 0.08
config.macos_window_background_blur = 60
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

-- Remember window size across restarts (WezTerm doesn't do this natively):
-- save pixel size on every resize, restore it when a new GUI window spawns.
local mux = wezterm.mux
local SIZE_STATE_DIR = wezterm.home_dir .. "/.local/state/wezterm"
local SIZE_STATE_PATH = SIZE_STATE_DIR .. "/size.json"

wezterm.on("window-resized", function(window, pane)
	local dims = window:get_dimensions()
	if dims.is_full_screen then
		return
	end
	os.execute("mkdir -p " .. SIZE_STATE_DIR)
	local f = io.open(SIZE_STATE_PATH, "w")
	if f then
		f:write(wezterm.json_encode({ width = dims.pixel_width, height = dims.pixel_height }))
		f:close()
	end
end)

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	local f = io.open(SIZE_STATE_PATH, "r")
	if f then
		local ok, size = pcall(wezterm.json_parse, f:read("*a"))
		f:close()
		if ok and gui_window and size and size.width and size.height then
			gui_window:set_inner_size(size.width, size.height)
			local screen = wezterm.gui.screens().main
			gui_window:set_position(
				screen.x + (screen.width - size.width) / 2,
				screen.y + (screen.height - size.height) / 2
			)
		end
	end
end)

return config
