-- Initialize Configuration
local wezterm = require("wezterm")
local config = wezterm.config_builder()

local home = os.getenv("HOME")
local data_folder = os.getenv("XDG_DATA_HOME") .. "/wezterm"

-- Font
config.font = wezterm.font_with_fallback({
	{
		family = "Iosevka NFP",
		weight = "Regular",
	},
	{
		family = "Lilex Nerd Font Propo",
		weight = "Regular",
	},
	{
		family = "FiraCode Nerd Font",
		weight = "Regular",
	},
	"Segoe UI Emoji",
})
config.warn_about_missing_glyphs = false

config.font_size = 10.5
config.underline_thickness = "400%"
config.underline_position = "200%"
config.adjust_window_size_when_changing_font_size = false

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	if name == "ZEN_MODE" then
		local incremental = value:find("+")
		local number_value = tonumber(value)
		if incremental ~= nil then
			while number_value > 0 do
				window:perform_action(wezterm.action.IncreaseFontSize, pane)
				number_value = number_value - 1
			end
			overrides.enable_tab_bar = false
		elseif number_value < 0 then
			window:perform_action(wezterm.action.ResetFontSize, pane)
			overrides.font_size = nil
			overrides.enable_tab_bar = true
		else
			overrides.font_size = number_value
			overrides.enable_tab_bar = false
		end
	end
	window:set_config_overrides(overrides)
end)

local bell_sound = wezterm.config_dir .. "/bell.mp3"
config.audible_bell = "Disabled"
wezterm.on("bell", function(
	_ --[[window]],
	_ --[[pane]]
)
	os.execute('ffplay "' .. bell_sound .. '" -autoexit -nodisp')
end)

local gui = wezterm.gui
if gui then
	for _, gpu in ipairs(gui.enumerate_gpus()) do
		-- if gpu.backend == "Dx12" and gpu.device_type == "DiscreteGpu" then
		-- 	config.webgpu_preferred_adapter = gpu
		-- 	config.front_end = "WebGpu"
		-- end
		if gpu.backend == "Gl" and gpu.device_type == "DiscreteGpu" then
			config.webgpu_preferred_adapter = gpu
			config.front_end = "OpenGL"
		end
	end
end

-- Window
config.initial_rows = 55
config.initial_cols = 235
config.window_decorations = "RESIZE"
-- config.win32_system_backdrop = "Acrylic"
config.max_fps = 60
config.animation_fps = 60
config.cursor_blink_rate = 250
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- color schemes
local light_scheme = "Catppuccin Latte"
local dark_scheme = "Catppuccin Mocha"

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		wezterm.log_error("Could not open file: " .. path)
		return nil
	end
	local content = f:read("*a")
	f:close()
	return content
end

local function read_json(path)
	local content = read_file(path)
	if not content then
		return {}
	end
	local ok, data = pcall(wezterm.json_parse, content)
	if not ok then
		wezterm.log_error("Error decoding JSON: " .. tostring(data))
		return {}
	end
	return data
end

local astronomy = read_json(os.getenv("XDG_STATE_HOME") .. "/astronomy.json")

local function seconds_until_theme_switch(current_hour, current_minute)
	local minutes_per_day = 24 * 60
	local current_total = current_hour * 60 + current_minute

	local dark_total = (astronomy.today.sunset.hour * 60)
		+ astronomy.today.sunset.minute
	local light_total = (astronomy.today.sunrise.hour * 60)
		+ astronomy.today.sunrise.minute

	-- Time until each switch (mod to handle wraparound)
	local until_dark = (dark_total - current_total) % minutes_per_day
	local until_light = (light_total - current_total) % minutes_per_day

	local next_minutes = math.min(
		until_dark > 0 and until_dark or minutes_per_day,
		until_light > 0 and until_light or minutes_per_day
	)

	return next_minutes * 60
end

local function time_to_seconds(hour, min)
	return hour * 3600 + min * 60
end

local function now_in_seconds()
	local now = os.date("*t")
	return now.hour * 3600 + now.min * 60 + now.sec
end

local function get_scheme_for_time()
	local now = now_in_seconds()
	if
		now
			>= time_to_seconds(
				astronomy.today.sunrise.hour,
				astronomy.today.sunrise.minute
			)
		and now
			< time_to_seconds(
				astronomy.today.sunset.hour,
				astronomy.today.sunset.minute
			)
	then
		return light_scheme
	else
		return dark_scheme
	end
end

-- schedule reload at next switch
-- schedule a single reload at next switch
local function schedule_next_switch()
	if wezterm.GLOBAL_THEME_SCHEDULED then
		wezterm.log_info("Theme switch already scheduled, skipping")
		return
	end

	wezterm.GLOBAL_THEME_SCHEDULED = true
	local hour = tonumber(os.date("%H"))
	local minute = tonumber(os.date("%M"))
	local delay = seconds_until_theme_switch(hour, minute)
	wezterm.log_info("Scheduling next theme switch in " .. delay .. " seconds")

	wezterm.time.call_after(delay, function()
		wezterm.log_info("Triggering theme reload now")
		wezterm.GLOBAL_THEME_SCHEDULED = false -- allow re-scheduling after reload
		wezterm.reload_configuration()
	end)
end

-- Set the initial scheme
config.color_scheme = get_scheme_for_time()
schedule_next_switch()

-- config.color_scheme = dark_scheme
config.force_reverse_video_cursor = true
config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = 1.0,
}

config.background = {
	{
		source = {
			Color = wezterm.get_builtin_color_schemes()[config.color_scheme].background,
		},
		opacity = 0.89,
		width = "100%",
		height = "100%",
	},
	{
		source = {
			File = "E:/pictures/flowers3.gif",
		},
		opacity = 0.1,
		width = 400 .. "px",
		height = 38 .. "px",
		repeat_x = "Mirror",
		repeat_y = "NoRepeat",
		horizontal_align = "Left",
		vertical_align = "Bottom",
	},
	{
		source = {
			File = "E:/pictures/foggs/tatujapatuah.gif",
		},
		opacity = 0.1,
		width = 100 * 1.5 .. "px",
		height = 100 * 1.5 .. "px",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		horizontal_align = "Right",
		vertical_align = "Bottom",
		horizontal_offset = "-11%",
		vertical_offset = "-2%",
	},
	{
		source = {
			File = "E:/pictures/foggs/xenia-2.png",
		},
		opacity = 0.2,
		width = 1452 / 4 .. "px",
		height = 1700 / 4 .. "px",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		vertical_align = "Bottom",
		horizontal_align = "Right",
	},
	{
		source = {
			File = "E:/pictures/foggs/foxlick.png",
		},
		opacity = 0.12,
		width = 600 / 2 .. "px",
		height = 600 / 2 .. "px",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		vertical_align = "Bottom",
		horizontal_align = "Left",
		horizontal_offset = "-2%",
	},
	{
		source = {
			File = "E:/pictures/10thprestigebby.gif",
		},
		opacity = 0.1,
		width = 200 / 2 .. "px",
		height = 200 / 2 .. "px",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		horizontal_align = "Left",
		vertical_align = "Bottom",
		horizontal_offset = "20%",
		-- vertical_offset = "-10%",
	},
	{
		source = {
			File = "E:/pictures/weed-leaf.gif",
		},
		opacity = 0.1,
		width = 128 * 0.8 .. "px",
		height = 128 * 0.8 .. "px",
		repeat_x = "NoRepeat",
		repeat_y = "NoRepeat",
		horizontal_align = "Left",
		vertical_align = "Bottom",
		horizontal_offset = "2.5%",
		vertical_offset = "-27%",
	},
}

local lm = setmetatable({}, {
	__index = {
		add = function(self, entry)
			table.insert(self, entry)
		end,
	},
})

-- Shell
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	lm:add({
		label = "Nushell",
		args = { "nu" },
	})
	lm:add({
		label = "Cmd",
		args = { "cmd", "/k", "cls" },
	})
	lm:add({
		label = "WSL: Arch",
		args = { "wsl", "-d", "Arch" },
		cwd = [[\\wsl$\Arch\home\effie]],
	})
	lm:add({
		label = "Bash",
		args = { "bash", "-l" },
	})
	lm:add({
		label = "PowerShell",
		args = { "pwsh", "-NoLogo" },
	})
	lm:add({
		label = "Apollyon",
		args = { "ssh", "effie@10.0.1.35" },
	})
	lm:add({
		label = "Media Server",
		args = { "ssh", "-p", "869", "effie@192.168.0.8" },
	})
	-- config.default_prog = { "wsl", "-d", "Arch" }
	-- config.default_cwd = [[\\wsl$\Arch\home\effie]]
	config.default_prog = { "nu" }
	config.default_cwd = [[~]]
end

config.launch_menu = lm

-- Tabs
config.enable_tab_bar = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 40
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

wezterm.on(
	"format-tab-title",
	function(tab, tabs, panes, config, hover, max_width)
		local index = " "
		if #tabs > 1 then
			index = string.format(" %d ", tab.tab_index + 1)
		end

		local title = tab.active_pane.title
		local hasPath = title:find("%a:\\")
		if hasPath then
			local path_start, path_end = title:find("%a:\\.+\\")
			local path = title:sub(path_start, path_end)
			title = title:gsub(title:sub(path_start, path_end), "\\")
		end

		local tab_content = string.format("%s%s ", index, title)

		if #tab_content > config.tab_max_width then
			tab_content = tab_content:sub(1, 8)
				.. "..."
				.. tab_content:sub(#tab_content - 26, #tab_content)
		end

		return tab_content
	end
)

wezterm.on("update-right-status", function(window, pane)
	local status = window:active_workspace()

	if window:get_dimensions().is_full_screen then
		status = status .. wezterm.strftime(" %R ")
	end

	window:set_right_status(wezterm.format({
		{ Text = status },
	}))
end)

local workspace_switcher = wezterm.plugin.require(
	"https://github.com/MLFlexer/smart_workspace_switcher.wezterm"
)

wezterm.on(
	"smart_workspace_switcher.workspace_switcher.chosen",
	function(window, workspace)
		local gui_win = window:gui_window()
		local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
		gui_win:set_right_status(wezterm.format({
			{ Foreground = { Color = "green" } },
			{ Text = base_path .. "  " },
		}))
	end
)

wezterm.on(
	"smart_workspace_switcher.workspace_switcher.created",
	function(window, workspace)
		local gui_win = window:gui_window()
		local base_path = string.gsub(workspace, "(.*[/\\])(.*)", "%2")
		gui_win:set_right_status(wezterm.format({
			{ Foreground = { Color = "green" } },
			{ Text = base_path .. "  " },
		}))
	end
)
config.disable_default_key_bindings = true
config.leader = { key = "g", mods = "CTRL" }

-- Keybindings
config.keys = {
	{
		key = "P",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateCommandPalette,
	},
	{
		key = "a",
		mods = "LEADER|CTRL",
		action = wezterm.action({ SendString = "\x01" }),
	},
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action({
			SplitVertical = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = wezterm.action({
			SplitHorizontal = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action({
			SplitVertical = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action({
			SplitHorizontal = { domain = "CurrentPaneDomain" },
		}),
	},
	{ key = "o", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
	},
	{
		key = "h",
		mods = "ALT",
		action = wezterm.action({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "j",
		mods = "ALT",
		action = wezterm.action({ ActivatePaneDirection = "Down" }),
	},
	{
		key = "k",
		mods = "ALT",
		action = wezterm.action({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "l",
		mods = "ALT",
		action = wezterm.action({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "H",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }),
	},
	{
		key = "J",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }),
	},
	{
		key = "K",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }),
	},
	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }),
	},
	{
		key = "1",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 0 }),
	},
	{
		key = "2",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 1 }),
	},
	{
		key = "3",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 2 }),
	},
	{
		key = "4",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 3 }),
	},
	{
		key = "5",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 4 }),
	},
	{
		key = "6",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 5 }),
	},
	{
		key = "7",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 6 }),
	},
	{
		key = "8",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 7 }),
	},
	{
		key = "9",
		mods = "LEADER",
		action = wezterm.action({ ActivateTab = 8 }),
	},
	{
		key = "&",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ CloseCurrentTab = { confirm = true } }),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action({ CloseCurrentPane = { confirm = true } }),
	},

	{ key = "UpArrow", mods = "ALT", action = wezterm.action.ScrollByLine(-1) },
	{
		key = "DownArrow",
		mods = "ALT",
		action = wezterm.action.ScrollByLine(1),
	},

	{
		key = "f",
		mods = "LEADER",
		action = workspace_switcher.switch_workspace(),
	},
	-- Remap paste for clipboard history compatibility
	{
		key = "v",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ PasteFrom = "Clipboard" }),
	},
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},

	{
		key = "=",
		mods = "CTRL",
		action = wezterm.action.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "CTRL",
		action = wezterm.action.DecreaseFontSize,
	},
}

local smart_splits =
	wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
smart_splits.apply_to_config(config, {
	-- the default config is here, if you'd like to use the default keys,
	-- you can omit this configuration table parameter and just use
	-- smart_splits.apply_to_config(config)

	-- directional keys to use in order of: left, down, up, right
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	-- if you want to use separate direction keys for move vs. resize, you
	-- can also do this:
	-- modifier keys to combine with direction_keys
	modifiers = {
		move = "ALT", -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = "SHIFT", -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
	-- log level to use: info, warn, error
	log_level = "info",
})

return config
