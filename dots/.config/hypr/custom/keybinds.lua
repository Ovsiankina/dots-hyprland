-- See https://wiki.hypr.land/configuring/basics/binds/
-- (examples assume: local vars = require("hyprland.variables"))
-- Lua form: hl.bind("MOD + MOD + KEY", hl.dsp.exec_cmd("..."), { description = "..." })
-- NOTE: the quickshell cheatsheet still parses custom/keybinds.conf (hyprlang syntax), not this file.
--!
---! User
-- hl.bind("Ctrl + Super + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json")) -- Edit shell config
-- hl.bind("Ctrl + Super + Alt + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua")) -- Edit extra keybinds

---! Apps
-- hl.bind("Super + Return", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "${TERMINAL}" "kitty -1" "foot" "alacritty" "wezterm" "konsole" "kgx" "uxterm" "xterm"]])) -- Terminal
-- hl.bind("Super + T", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh  "${TERMINAL}" "kitty -1" "foot" "alacritty" "wezterm" "konsole" "kgx" "uxterm" "xterm"]])) -- [hidden] (terminal) (alt)
-- hl.bind("Ctrl + Alt + T", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "${TERMINAL}" "kitty -1" "foot" "alacritty" "wezterm" "konsole" "kgx" "uxterm" "xterm"]])) -- [hidden] (terminal) (for Ubuntu people)
-- hl.bind("Super + E", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "dolphin" "nautilus" "nemo" "thunar" "${TERMINAL}" "kitty -1 fish -c yazi"]])) -- File manager
-- hl.bind("Super + W", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "google-chrome-stable" "zen-browser" "firefox" "brave" "chromium" "microsoft-edge-stable" "opera" "librewolf"]])) -- Browser
-- hl.bind("Super + C", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "code" "codium" "cursor" "zed" "zedit" "zeditor" "kate" "gnome-text-editor" "emacs" "command -v nvim && kitty -1 nvim" "command -v micro && kitty -1 micro"]])) -- Code editor
-- hl.bind("Ctrl + Super + Shift + Alt + W", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "wps" "onlyoffice-desktopeditors" "libreoffice"]])) -- Office software
-- hl.bind("Super + X", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "kate" "gnome-text-editor" "emacs"]])) -- Text editor
-- hl.bind("Ctrl + Super + V", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "pavucontrol-qt" "pavucontrol"]])) -- Volume mixer
-- hl.bind("Super + I", hl.dsp.exec_cmd([[XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh "qs -p ~/.config/quickshell/]] .. vars.qsConfig .. [[/settings.qml" "systemsettings" "gnome-control-center" "better-control"]])) -- Settings app
-- hl.bind("Ctrl + Shift + Escape", hl.dsp.exec_cmd([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "gnome-system-monitor" "plasma-systemmonitor --page-name Processes" "command -v btop && kitty -1 fish -c btop"]])) -- Task manager

-- Add stuff here
-- Use --! to add an extra column on the cheatsheet (mirrors #! in keybinds.conf)
-- Use ---! to add a section in that column (mirrors ##!)
-- Add a comment after a bind to add a description, like above

-- IMPORTANT: all active binds live in the "global" submap (see hyprland/keybinds.lua). A top-level
-- hl.bind here would land in the default submap, which is never active, and silently do nothing.
-- Put your binds inside this block:
hl.define_submap("global", function()
    -- hl.bind("Super + X", hl.dsp.exec_cmd("..."), { description = "..." })
end)
