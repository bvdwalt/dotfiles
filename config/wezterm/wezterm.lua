-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

local function brightness_auto_adjust(hex, amount)
  -- Ensure the hex is 6 characters long (RGB) and amount is within 0 to 1 range
  if #hex ~= 7 or hex:sub(1, 1) ~= "#" then
    error("Invalid hex color format. Expected format: #RRGGBB")
  end

  amount = math.min(math.max(amount, 0), 1) -- Clamp amount to [0, 1]

  -- Extract the color components from the hex string
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  -- Calculate the brightness of the color (relative luminance)
  local brightness = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255

  -- Adjust each color channel: brighten dark colors, dim bright colors
  if brightness < 0.5 then
    r = math.min(255, math.floor(r + (255 - r) * amount))
    g = math.min(255, math.floor(g + (255 - g) * amount))
    b = math.min(255, math.floor(b + (255 - b) * amount))
  else
    r = math.max(0, math.floor(r * (1 - amount)))
    g = math.max(0, math.floor(g * (1 - amount)))
    b = math.max(0, math.floor(b * (1 - amount)))
  end

  -- Format the result back into a hex color string
  local new_hex = string.format("#%02X%02X%02X", r, g, b)
  return new_hex
end

local function getDirectoryName(path)
  if not path then
    return 'Unknown'
  end
  -- Remove any trailing slashes from the path
  path = path:gsub("/+$", "")
  -- Extract the last part of the path (the directory name)
  local directoryName = path:match("([^/]+)$")
  return directoryName or 'Unknown'
end

local process_icons = { -- for get_process function
  ['docker'] = wezterm.nerdfonts.linux_docker,
  ['docker-compose'] = wezterm.nerdfonts.linux_docker,
  ['psql'] = wezterm.nerdfonts.dev_postgresql,
  ['kuberlr'] = wezterm.nerdfonts.linux_docker,
  ['kubectl'] = wezterm.nerdfonts.linux_docker,
  ['stern'] = wezterm.nerdfonts.linux_docker,
  ['nvim'] = wezterm.nerdfonts.custom_vim,
  ['make'] = wezterm.nerdfonts.seti_makefile,
  ['vim'] = wezterm.nerdfonts.dev_vim,
  ['go'] = wezterm.nerdfonts.seti_go,
  ['zsh'] = wezterm.nerdfonts.dev_terminal,
  ['bash'] = wezterm.nerdfonts.cod_terminal_bash,
  ['btm'] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ['htop'] = wezterm.nerdfonts.mdi_chart_donut_variant,
  ['cargo'] = wezterm.nerdfonts.dev_rust,
  ['sudo'] = wezterm.nerdfonts.fa_hashtag,
  ['lazydocker'] = wezterm.nerdfonts.linux_docker,
  ['git'] = wezterm.nerdfonts.dev_git,
  ['lua'] = wezterm.nerdfonts.seti_lua,
  ['wget'] = wezterm.nerdfonts.mdi_arrow_down_box,
  ['curl'] = wezterm.nerdfonts.mdi_flattr,
  ['gh'] = wezterm.nerdfonts.dev_github_badge,
  ['ruby'] = wezterm.nerdfonts.cod_ruby,
  ['pwsh'] = wezterm.nerdfonts.seti_powershell,
  ['node'] = wezterm.nerdfonts.dev_nodejs_small,
  ['dotnet'] = wezterm.nerdfonts.md_language_csharp,
}

local function get_process(tab)
  local process_name = tab.active_pane.foreground_process_name:match("([^/\\]+)%.exe$") or
      tab.active_pane.foreground_process_name:match("([^/\\]+)$")

  -- local icon = process_icons[process_name] or string.format('[%s]', process_name)
  local icon = process_icons[process_name] or wezterm.nerdfonts.seti_checkbox_unchecked

  return icon
end


-- This will hold the configuration.
local config = wezterm.config_builder()

config.max_fps = 120

-- FONTS:
config.font = wezterm.font("FiraCode Nerd Font", { weight = "Light", stretch = "Normal", style = "Normal" })
config.font_rules = {
  -- Bold-not-italic
  {
    intensity = 'Bold',
    italic = false,
    font = wezterm.font_with_fallback {
      {
        family = 'FiraCode Nerd Font',
        weight = 'ExtraBold',
      }
    }
  },
  -- Bold-and-italic
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font_with_fallback {
      {
        family = 'FiraCode Nerd Font',
        weight = 'ExtraBold',
        italic = true
      }
    }
  },
  -- normal-intensity-and-italic
  {
    intensity = 'Normal',
    italic = false,
    font = wezterm.font_with_fallback {
      {
        family = 'FiraCode Nerd Font',
        weight = 'DemiBold',
      }
    }
  },
  -- half-intensity-and-italic (half-bright or dim)
  {
    intensity = 'Half',
    italic = true,
    font = wezterm.font_with_fallback {
      {
        family = 'FiraCode Nerd Font',
        weight = 'Light',
        italic = true
      }
    }
  },
  -- half-intensity-and-not-italic
  {
    intensity = 'Half',
    italic = false,
    font = wezterm.font_with_fallback {
      {
        family = 'FiraCode Nerd Font',
        weight = 'Light'
      }
    }
  }
}

config.font_size = 12

local scheme = 'Dracula'

local scheme_def = wezterm.color.get_builtin_schemes()[scheme]

-- For loading a local color scheme:
-- local scheme = 'ayu modified'
-- local scheme_def = wezterm.color.load_scheme(wezterm.home_dir .. '/.config/wezterm/colors/ayu-modified.toml')

config.color_scheme = scheme

-- Calculating colors for the UI, based on the scheme_def.background color:
local color_bg_100 = brightness_auto_adjust(scheme_def.background, 0.100)
local color_bg_165 = brightness_auto_adjust(scheme_def.background, 0.165)
local color_bg_300 = brightness_auto_adjust(scheme_def.background, 0.300)
local color_bg_500 = brightness_auto_adjust(scheme_def.background, 0.500)
local color_hl = scheme_def.cursor_bg or scheme_def.cursor_selection_bg or scheme_def.foreground

-- config.window_background_opacity = 0.96
-- config.macos_window_background_blur = 10

-- Sizings and Spacings:
config.window_padding = {
  left = 24,
  right = 24,
  top = 24,
  bottom = 12
}

config.initial_cols = 93
config.initial_rows = 45

-- TABBAR:
config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

config.window_frame = {
  -- The font used in the tab bar.
  -- Roboto Bold is the default; this font is bundled
  -- with wezterm.
  -- Whatever font is selected here, it will have the
  -- main font setting appended to it to pick up any
  -- fallback fonts you may have used there.
  font                 = wezterm.font { family = 'Roboto', weight = 'DemiBold' },

  -- The size of the font in the tab bar.
  -- Default to 10.0 on Windows but 12.0 on other systems
  font_size            = 12,

  -- The overall background color of the tab bar when
  -- the window is focused
  active_titlebar_bg   = color_bg_165,

  -- The overall background color of the tab bar when
  -- the window is not focused
  inactive_titlebar_bg = color_bg_100,
  -- inactive_titlebar_bg  = scheme_def.brights[1],

  -- border_top_height = '0.03cell',
  border_bottom_height = '1px',
  border_left_width    = '1px',
  border_right_width   = '1px',

  -- border_top_color = brightness_auto_adjust(scheme_def.background, 0.3),
  border_bottom_color  = color_bg_300,
  border_left_color    = color_bg_300,
  border_right_color   = color_bg_300,
}

config.colors = {
  tab_bar = {
    -- The color of the inactive tab bar edge/divider
    inactive_tab_edge = color_bg_500,

    active_tab = {
      bg_color = scheme_def.background,
      fg_color = scheme_def.foreground,
    },

    inactive_tab = {
      bg_color = 'none',
      fg_color = color_bg_500,
    },
  }
}

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local cwd_uri = pane.current_working_dir
  local directoryName = 'Unknown'
  local process = get_process(tab)

  if cwd_uri then
    -- Convert the URI to a string, remove the hostname, and decode %20s:
    local cwd_path = cwd_uri.file_path
    -- cwd_path = cwd_path:gsub("^file://[^/]+", "") -- not needed
    -- cwd_path = decodeURI(cwd_path) -- not needed

    -- Extract the directory name from the decoded path:
    directoryName = getDirectoryName(cwd_path)
  end

  local title = string.format(' ⌘%s  %s  %s', (tab.tab_index + 1), directoryName, process)

  return {
    { Text = title },
  }
end)

-- STATUS BAR:
wezterm.on('update-right-status', function(window)
  window:set_right_status(wezterm.format({
    { Foreground = { Color = scheme_def.foreground } },
    { Background = { Color = 'none' } },

    { Text = wezterm.nerdfonts.oct_table .. " " .. workspace_or_leader },

    { Text = " | " },

    { Text = wezterm.nerdfonts.md_folder .. " " .. directoryName },

    { Text = " | " },

    -- { Text = wezterm.nerdfonts.oct_person .. " " .. hostname },
    -- { Text = "| " },

    { Foreground = { Color = color_hl } },
    { Background = { Color = 'none' } },

    { Text = wezterm.nerdfonts.fa_code .. " " .. cmd },

    -- "ResetAttributes",
    { Foreground = { Color = scheme_def.foreground } },
    { Background = { Color = 'none' } },

    -- { Text = " | " },
    -- { Text = wezterm.nerdfonts.md_clock .. " " .. time },
    -- { Text = " | " },
    -- { Text = "   " },
  }))
end)

-- KEY BINDINGS:
config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'f',
      mods = 'ALT'
    },
  },
  -- Clears the scrollback and viewport, and then sends CTRL-L to ask the
  -- shell to redraw its prompt
  {
    key = 'k',
    mods = 'SUPER',
    action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },
}

-- and finally, return the configuration to wezterm
return config
