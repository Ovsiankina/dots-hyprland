-- This file requires other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`
-- (Lua port of hyprland.conf; Hyprland 0.57.1 only loads this file.)

-- `$qsConfig = ii` lives in hyprland/variables.lua; modules that need it do require("hyprland.variables")
-- The old `exec = hyprctl dispatch submap global` + `submap = global` lines (required for
-- catchall to work, and for any keybind to work at all) are handled inside
-- hyprland/keybinds.lua: it defines submap "global" and enters it on config.reloaded.

-- Environment variables
require("hyprland.env")
-- (hyprland/variables.lua is required by the modules that need qsConfig)
-- require("custom.env")

-- Defaults
require("hyprland.execs")
-- require("hyprland.monitors")
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")
require("hyprland.keybinds")

-- Custom
require("custom.execs")
require("custom.general")
require("custom.rules")
require("custom.keybinds")

-- nwg-displays support (optional files, nwg-displays writes them)
pcall(require, "workspaces")
pcall(require, "monitors")

-- Shell overrides (must stay LAST: applies quickshell's hyprland/shellOverrides/main.conf)
require("hyprland.shellOverrides.main")
