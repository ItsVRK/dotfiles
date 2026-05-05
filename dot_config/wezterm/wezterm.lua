local wezterm = require "wezterm"
local config = wezterm.config_builder()
-- This is where you actually apply your config choices

config.enable_kitty_keyboard = true
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")
config.font_size = 14

config.window_padding = { left = '0.5cell', right = '1.5cell', top = '0.5cell', bottom = '0.5cell' }

config.enable_scroll_bar = true
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

local function schemeforappearance(appearance)
    if appearance:find "Dark" then
        return "Monokai Remastered"
    else
        return "Grass (Gogh)"
    end
end

config.color_scheme = schemeforappearance(wezterm.gui.get_appearance())

config.keys = {
    { key = 'd',          mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'd',          mods = 'CMD',       action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    -- { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'w',          mods = 'CMD',       action = wezterm.action.CloseCurrentPane { confirm = false } },
    { key = 'w',          mods = 'CMD|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
    { key = 'LeftArrow',  mods = 'CMD',       action = wezterm.action.SendKey { key = 'Home' } },
    { key = 'RightArrow', mods = 'CMD',       action = wezterm.action.SendKey { key = 'End' } },
    { key = 'p',          mods = 'CMD|SHIFT', action = wezterm.action.ActivateCommandPalette },
    { mods = "OPT",       key = "LeftArrow",  action = wezterm.action.SendKey({ mods = "ALT", key = "b" }) },
    { mods = "OPT",       key = "RightArrow", action = wezterm.action.SendKey({ mods = "ALT", key = "f" }) },
    { mods = "CMD",       key = "LeftArrow",  action = wezterm.action.SendKey({ mods = "CTRL", key = "a" }) },
    { mods = "CMD",       key = "RightArrow", action = wezterm.action.SendKey({ mods = "CTRL", key = "e" }) },
    { mods = "CMD",       key = "Backspace",  action = wezterm.action.SendKey({ mods = "CTRL", key = "u" }) },
    { mods = 'CMD|ALT',   key = 'LeftArrow',  action = wezterm.action.ActivateTabRelative(-1) },
    { mods = 'CMD|ALT',   key = 'RightArrow', action = wezterm.action.ActivateTabRelative(1) },
}

return config
