-- Lua port of hyprland/keybinds.conf (Hyprland 0.57.1).
-- NOTE: keybinds.conf stays on disk untouched: quickshell's cheatsheet (HyprlandKeybinds.qml / get_keybinds.py)
-- still parses it. Keep both files in sync when changing binds.
--
-- Lines ending with `-- [hidden]` won't be shown on cheatsheet
-- Lines starting with `-- #!` are section headings
--
-- Old hyprland.conf header (ported here):
--   exec = hyprctl dispatch submap global # DO NOT REMOVE THIS OR YOU WON'T BE ABLE TO USE ANY KEYBIND
--   submap = global # This is required for catchall to work
-- -> every bind lives inside hl.define_submap("global", ...), and the "global" submap is entered on load
--    (see the hl.on(...) calls at the bottom of this file).

local vars = require("hyprland.variables")
local qsConfig = vars.qsConfig

local function exec(cmd) return hl.dsp.exec_cmd(cmd) end
local function global(name) return hl.dsp.global(name) end

hl.define_submap("global", function()

-- Basic window operations
hl.bind("SUPER + M", hl.dsp.exit())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + C", exec("hyprpicker -a"))

-- Window resizing (hjkl with SHIFT)
hl.bind("SUPER + SHIFT + l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind("SUPER + SHIFT + j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Workspace switching (numeric keys)
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind("SUPER + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

-- Move to workspace (SHIFT+numeric)
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Group management
-- bind = SUPER,g,togglegroup
-- bind = SUPER,tab,changegroupactive

-- Utilities
hl.bind("CTRL + 1", exec("~/.config/hypr/scripts/swap-windows.sh"))
hl.bind("SUPER + h", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + l", hl.dsp.focus({ workspace = "+1" }))
-- bind = Alt, Tab, cyclenext # [hidden] sus keybind
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top()) -- [hidden] bring it to the top

-- #!
-- ##! Shell
-- These absolutely need to be on top, or they won't work consistently
hl.bind("SUPER + P", global("quickshell:searchToggle"), { description = "Toggle search" }) -- Toggle search (press variant; release events broken since Hyprland 0.55.3)
hl.bind("SUPER + P", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pkill fuzzel || fuzzel")) -- [hidden] Launcher (fallback)
hl.bind("catchall", global("quickshell:searchToggleReleaseInterrupt"), { ignore_mods = true, transparent = true, non_consuming = true }) -- [hidden] (key must be exactly "catchall" to be a catch-all; ignore_mods covers the old Super modifier)
hl.bind("CTRL + Super_L", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("CTRL + Super_R", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:272", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:273", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:274", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:275", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:276", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse:277", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse_up", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]
hl.bind("SUPER + mouse_down", global("quickshell:searchToggleReleaseInterrupt")) -- [hidden]

hl.bind("Super_L", global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true }) -- [hidden]
hl.bind("Super_R", global("quickshell:workspaceNumber"), { ignore_mods = true, transparent = true }) -- [hidden]
hl.bind("SUPER + J", global("quickshell:overviewToggleRelease")) -- Toggle overview/launcher
hl.bind("SUPER + Tab", global("quickshell:overviewToggle"), { description = "Toggle overview", long_press = true }) -- [hidden] Toggle overview/launcher (alt)
hl.bind("SUPER + V", global("quickshell:overviewClipboardToggle"), { description = "Clipboard history >> clipboard" }) -- Clipboard history >> clipboard
hl.bind("SUPER + E", global("quickshell:overviewEmojiToggle"), { description = "Emoji >> clipboard" }) -- Emoji >> clipboard
hl.bind("SUPER + A", global("quickshell:sidebarLeftToggle")) -- Toggle left sidebar
hl.bind("SUPER + ALT + A", global("quickshell:sidebarLeftToggleDetach")) -- [hidden]
hl.bind("SUPER + B", global("quickshell:sidebarLeftToggle")) -- [hidden]
hl.bind("SUPER + O", global("quickshell:sidebarLeftToggle")) -- [hidden]
hl.bind("SUPER + N", global("quickshell:sidebarRightToggle"), { description = "Toggle right sidebar" }) -- Toggle right sidebar
hl.bind("SUPER + Slash", global("quickshell:cheatsheetToggle"), { description = "Toggle cheatsheet" }) -- Toggle cheatsheet
hl.bind("SUPER + K", global("quickshell:oskToggle"), { description = "Toggle on-screen keyboard" }) -- Toggle on-screen keyboard
hl.bind("SUPER + D", global("quickshell:mediaControlsToggle"), { description = "Toggle media controls" }) -- Toggle media controls
hl.bind("SUPER + G", global("quickshell:overlayToggle")) -- Toggle overlay
hl.bind("CTRL + ALT + Delete", global("quickshell:sessionToggle"), { description = "Toggle session menu" }) -- Toggle session menu
hl.bind("SUPER + J", global("quickshell:barToggle"), { description = "Toggle bar" }) -- Toggle bar
hl.bind("CTRL + ALT + Delete", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pkill wlogout || wlogout -p layer-shell")) -- [hidden] Session menu (fallback)
hl.bind("SHIFT + SUPER + ALT + Slash", exec("qs -p ~/.config/quickshell/" .. qsConfig .. "/welcome.qml")) -- [hidden] Launch welcome app

hl.bind("XF86MonBrightnessUp", exec("qs -c " .. qsConfig .. " ipc call brightness increment || brightnessctl s 5%+"), { locked = true, repeating = true }) -- [hidden]
hl.bind("XF86MonBrightnessDown", exec("qs -c " .. qsConfig .. " ipc call brightness decrement || brightnessctl s 5%-"), { locked = true, repeating = true }) -- [hidden]
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.5"), { locked = true, repeating = true }) -- [hidden]
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true }) -- [hidden]

hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true }) -- [hidden]
hl.bind("SUPER + SHIFT + M", exec("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true, description = "Toggle mute" }) -- [hidden]
hl.bind("ALT + XF86AudioMute", exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true }) -- [hidden]
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true }) -- [hidden]
hl.bind("SUPER + ALT + M", exec("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true, description = "Toggle mic" }) -- [hidden]
hl.bind("CTRL + SUPER + T", global("quickshell:wallpaperSelectorToggle"), { description = "Toggle wallpaper selector" }) -- Wallpaper selector
hl.bind("CTRL + SUPER + ALT + T", global("quickshell:wallpaperSelectorRandom"), { description = "Select random wallpaper" }) -- Random wallpaper
hl.bind("CTRL + SUPER + T", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || ~/.config/quickshell/" .. qsConfig .. "/scripts/colors/switchwall.sh"), { description = "Change wallpaper" }) -- [hidden] Change wallpaper (fallback)
hl.bind("CTRL + SUPER + R", exec("killall ags agsv1 gjs ydotool qs quickshell; qs -c " .. qsConfig .. " &")) -- Restart widgets
hl.bind("CTRL + SUPER + P", global("quickshell:panelFamilyCycle")) -- Cycle panel family

-- ##! Utilities
-- Screenshot, Record, OCR, Color picker, Clipboard history
hl.bind("SUPER + V", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"), { description = "Copy clipboard history entry" }) -- [hidden] Clipboard history >> clipboard (fallback)
hl.bind("SUPER + Period", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pkill fuzzel || ~/.config/hypr/hyprland/scripts/fuzzel-emoji.sh copy"), { description = "Copy an emoji" }) -- [hidden] Emoji >> clipboard (fallback)
hl.bind("SUPER + SHIFT + S", global("quickshell:regionScreenshot")) -- Screen snip
hl.bind("SUPER + SHIFT + S", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent")) -- [hidden] Screen snip (fallback)
-- (only change vs .conf: the inner `hyprctl dispatch global quickshell:regionScreenshot` is rewritten to the 0.57.1 Lua form)
hl.bind("SUPER + SHIFT + D", exec([[sh -c 'dir="$(jq -r ".screenSnip.savePath // empty" "$HOME/.config/illogical-impulse/config.json")"; [ -z "$dir" ] && notify-send "Screen snip savePath is empty" && exit 1; before="$(ls -1t "$dir"/screenshot-*.png 2>/dev/null | sed -n "1p")"; hyprctl dispatch "hl.dsp.global(\"quickshell:regionScreenshot\")"; for i in $(seq 1 120); do now="$(ls -1t "$dir"/screenshot-*.png 2>/dev/null | sed -n "1p")"; [ -n "$now" ] && [ "$now" != "$before" ] && { pinta "$now"; exit 0; }; sleep 0.1; done; notify-send "No new snip file found for Pinta"']])) -- Native screen snip >> Pinta
hl.bind("SUPER + SHIFT + A", global("quickshell:regionSearch")) -- Google Lens
hl.bind("SUPER + SHIFT + A", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || pidof slurp || ~/.config/hypr/hyprland/scripts/snip_to_search.sh")) -- [hidden] Google Lens (fallback)
-- OCR
hl.bind("SUPER + SHIFT + T", global("quickshell:regionOcr")) -- Character recognition >> clipboard
-- bind = Super+Shift, T,exec, qs -c $qsConfig ipc call TEST_ALIVE || pidof slurp || grim -g "$(slurp $SLURP_ARGS)" "/tmp/ocr_image.png" && tesseract "/tmp/ocr_image.png" stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/') | wl-copy && rm "/tmp/ocr_image.png" # [hidden]
-- Color picker
hl.bind("SUPER + SHIFT + C", exec("hyprpicker -a"), { description = "Color picker" }) -- Pick color (Hex) >> clipboard
-- Fullscreen screenshot
hl.bind("Print", exec("grim - | wl-copy"), { locked = true }) -- Screenshot >> clipboard
hl.bind("CTRL + Print", exec([[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim $(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]), { locked = true, non_consuming = true }) -- Screenshot >> clipboard & file (file)
hl.bind("CTRL + Print", exec("grim - | wl-copy"), { locked = true, non_consuming = true }) -- [hidden] Screenshot >> clipboard & file (clipboard)
-- Recording stuff
hl.bind("SUPER + SHIFT + R", global("quickshell:regionRecord"), { locked = true }) -- Record region (no sound)
-- bindl = Super+Shift, R, exec, qs -c $qsConfig ipc call TEST_ALIVE || ~/.config/quickshell/$qsConfig/scripts/videos/record.sh # [hidden] Record region (no sound) (fallback)
-- bindl = Super+Alt, R, global, quickshell:regionRecord # [hidden] Record region (no sound)
-- bindl = Super+Alt, R, exec, qs -c $qsConfig ipc call TEST_ALIVE || ~/.config/quickshell/$qsConfig/scripts/videos/record.sh # [hidden] Record region (no sound) (fallback)
-- bindl = Ctrl+Alt, R, exec, ~/.config/quickshell/$qsConfig/scripts/videos/record.sh --fullscreen # [hidden] Record screen (no sound)
hl.bind("SUPER + SHIFT + V", global("quickshell:regionRecordWithSound"), { locked = true }) -- Record region (with sound)
-- AI
hl.bind("SUPER + SHIFT + ALT + mouse:273", exec("~/.config/hypr/hyprland/scripts/ai/primary-buffer-query.sh"), { description = "Generate AI summary for selected text" }) -- [hidden] AI summary for selected text

-- #!
-- ##! Window
-- Focusing
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true }) -- Move
hl.bind("SUPER + mouse:274", hl.dsp.window.drag(), { mouse = true }) -- [hidden]
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- Resize
-- #/# bind = Super, ←/↑/→/↓,, # Focus in direction
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "left" })) -- [hidden]
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "right" })) -- [hidden]
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "up" })) -- [hidden]
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "down" })) -- [hidden]
hl.bind("SUPER + BracketLeft", hl.dsp.focus({ direction = "left" })) -- [hidden]
hl.bind("SUPER + BracketRight", hl.dsp.focus({ direction = "right" })) -- [hidden]
-- #/# bind = Super+Shift, ←/↑/→/↓,, # Move in direction
-- Navigation (hjkl)
hl.bind("SUPER + CTRL + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + CTRL + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + CTRL + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + CTRL + j", hl.dsp.focus({ direction = "down" }))
-- `hyprctl kill` (click-to-kill mode) still exists in 0.57.1 hyprctl, so it is kept as-is.
-- hl.dsp.window.kill() would instead SIGKILL the *active* window immediately (different behaviour).
hl.bind("SUPER + CTRL + Q", exec("hyprctl kill")) -- Forcefully zap a window
hl.bind("SUPER + s", hl.dsp.window.swap({ next = true }))
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "left" })) -- [hidden]
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "right" })) -- [hidden]
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "up" })) -- [hidden]
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "down" })) -- [hidden]
hl.bind("ALT + F4", hl.dsp.window.close()) -- [hidden] Close (Windows)
hl.bind("SUPER + Q", hl.dsp.window.close()) -- Close
hl.bind("SUPER + SHIFT + ALT + Q", exec("hyprctl kill")) -- Forcefully zap a window


-- Window split ratio
-- #/# binde = Super, ;/',, # Adjust split ratio
hl.bind("SUPER + Semicolon", hl.dsp.layout("splitratio -0.1"), { repeating = true }) -- [hidden]
hl.bind("SUPER + Apostrophe", hl.dsp.layout("splitratio +0.1"), { repeating = true }) -- [hidden]
-- Positioning mode
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" })) -- Float/Tile
-- bind = Super, D, fullscreen, 1 # Maximize
-- bind = Super, F, fullscreen, 0 # Fullscreen
-- bind = Super+Alt, F, fullscreenstate, 0 3 # Fullscreen spoof
-- bind = Super, P, pin # Pin

-- #/# bind = Super+Alt, Hash,, # Send to workspace # (1, 2, 3,...)
-- We use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
hl.bind("SUPER + ALT + code:10", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 1")) -- [hidden]
hl.bind("SUPER + ALT + code:11", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 2")) -- [hidden]
hl.bind("SUPER + ALT + code:12", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 3")) -- [hidden]
hl.bind("SUPER + ALT + code:13", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 4")) -- [hidden]
hl.bind("SUPER + ALT + code:14", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 5")) -- [hidden]
hl.bind("SUPER + ALT + code:15", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 6")) -- [hidden]
hl.bind("SUPER + ALT + code:16", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 7")) -- [hidden]
hl.bind("SUPER + ALT + code:17", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 8")) -- [hidden]
hl.bind("SUPER + ALT + code:18", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 9")) -- [hidden]
hl.bind("SUPER + ALT + code:19", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 10")) -- [hidden]
-- keypad numbers
hl.bind("SUPER + ALT + code:87", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 1")) -- [hidden]
hl.bind("SUPER + ALT + code:88", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 2")) -- [hidden]
hl.bind("SUPER + ALT + code:89", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 3")) -- [hidden]
hl.bind("SUPER + ALT + code:83", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 4")) -- [hidden]
hl.bind("SUPER + ALT + code:84", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 5")) -- [hidden]
hl.bind("SUPER + ALT + code:85", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 6")) -- [hidden]
hl.bind("SUPER + ALT + code:79", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 7")) -- [hidden]
hl.bind("SUPER + ALT + code:80", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 8")) -- [hidden]
hl.bind("SUPER + ALT + code:81", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 9")) -- [hidden]
hl.bind("SUPER + ALT + code:90", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh movetoworkspacesilent 10")) -- [hidden]

-- # #/# bind = Super+Shift, Scroll ↑/↓,, # Send to workspace left/right
hl.bind("SUPER + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "r-1" })) -- [hidden]
hl.bind("SUPER + SHIFT + mouse_up", hl.dsp.window.move({ workspace = "r+1" })) -- [hidden]
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" })) -- [hidden]
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" })) -- [hidden]

-- #/# bind = Super+Shift, Page_↑/↓,, # Send to workspace left/right
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" })) -- [hidden]
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" })) -- [hidden]
hl.bind("SUPER + SHIFT + Page_Down", hl.dsp.window.move({ workspace = "r+1" })) -- [hidden]
hl.bind("SUPER + SHIFT + Page_Up", hl.dsp.window.move({ workspace = "r-1" })) -- [hidden]
hl.bind("CTRL + SUPER + SHIFT + Right", hl.dsp.window.move({ workspace = "r+1" })) -- [hidden]
hl.bind("CTRL + SUPER + SHIFT + Left", hl.dsp.window.move({ workspace = "r-1" })) -- [hidden]

-- movetoworkspacesilent == window.move with follow = false (0.57.1 source; `silent` is not a key it reads)
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false })) -- Send to scratchpad

hl.bind("CTRL + SUPER + S", hl.dsp.workspace.toggle_special()) -- [hidden]

-- ##! Workspace
-- Switching
-- #/# bind = Super, Hash,, # Focus workspace # (1, 2, 3,...)
-- We use raw keycodes because some keyboard layouts register number keys as different chars. The codes can be verified with `wev`
hl.bind("SUPER + code:10", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 1")) -- [hidden]
hl.bind("SUPER + code:11", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 2")) -- [hidden]
hl.bind("SUPER + code:12", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 3")) -- [hidden]
hl.bind("SUPER + code:13", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 4")) -- [hidden]
hl.bind("SUPER + code:14", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 5")) -- [hidden]
hl.bind("SUPER + code:15", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 6")) -- [hidden]
hl.bind("SUPER + code:16", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 7")) -- [hidden]
hl.bind("SUPER + code:17", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 8")) -- [hidden]
hl.bind("SUPER + code:18", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 9")) -- [hidden]
hl.bind("SUPER + code:19", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 10")) -- [hidden]
-- keypad numbers
hl.bind("SUPER + code:87", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 1"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:88", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 2"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:89", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 3"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:83", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 4"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:84", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 5"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:85", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 6"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:79", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 7"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:80", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 8"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:81", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 9"), { dont_inhibit = true }) -- [hidden]
hl.bind("SUPER + code:90", exec("~/.config/hypr/hyprland/scripts/workspace_action.sh workspace 10"), { dont_inhibit = true }) -- [hidden]

-- #/# bind = Ctrl+Super, ←/→,, # Focus left/right
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "r+1" })) -- [hidden]
hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "r-1" })) -- [hidden]
-- #/# bind = Ctrl+Super+Alt, ←/→,, # [hidden] Focus busy left/right
hl.bind("CTRL + SUPER + ALT + Right", hl.dsp.focus({ workspace = "m+1" })) -- [hidden]
hl.bind("CTRL + SUPER + ALT + Left", hl.dsp.focus({ workspace = "m-1" })) -- [hidden]
-- #/# bind = Super, Page_↑/↓,, # Focus left/right
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" })) -- [hidden]
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" })) -- [hidden]
hl.bind("CTRL + SUPER + Page_Down", hl.dsp.focus({ workspace = "r+1" })) -- [hidden]
hl.bind("CTRL + SUPER + Page_Up", hl.dsp.focus({ workspace = "r-1" })) -- [hidden]
-- #/# bind = Super, Scroll ↑/↓,, # Focus left/right
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" })) -- [hidden]
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" })) -- [hidden]
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "r+1" })) -- [hidden]
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "r-1" })) -- [hidden]
-- ## Special
-- bind = Super, S, togglespecialworkspace, # Toggle scratchpad
hl.bind("SUPER + mouse:275", hl.dsp.workspace.toggle_special()) -- [hidden]
hl.bind("CTRL + SUPER + BracketLeft", hl.dsp.focus({ workspace = "-1" })) -- [hidden]
hl.bind("CTRL + SUPER + BracketRight", hl.dsp.focus({ workspace = "+1" })) -- [hidden]
hl.bind("CTRL + SUPER + Up", hl.dsp.focus({ workspace = "r-5" })) -- [hidden]
hl.bind("CTRL + SUPER + Down", hl.dsp.focus({ workspace = "r+5" })) -- [hidden]

-- ##! Virtual machines
hl.bind("SUPER + ALT + F1", function()
    hl.dispatch(exec("notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. Hit Super+Alt+F1 to escape' -a 'Hyprland'"))
    hl.dispatch(hl.dsp.submap("virtual-machine"))
end) -- Disable keybinds
-- submap = virtual-machine
hl.define_submap("virtual-machine", function()
    hl.bind("SUPER + ALT + F1", function()
        hl.dispatch(exec("notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'"))
        hl.dispatch(hl.dsp.submap("global"))
    end) -- [hidden]
end)
-- submap = global

-- #!
-- Testing
hl.bind("SUPER + ALT + f11", exec([=[bash -c 'RANDOM_IMAGE=$(find ~/Pictures -type f | grep -v -i "nipple" | grep -v -i "pussy" | shuf -n 1); ACTION=$(notify-send "Test notification with body image" "This notification should contain your user account <b>image</b> and <a href=\"https://discord.com/app\">Discord</a> <b>icon</b>. Oh and here is a random image in your Pictures folder: <img src=\"$RANDOM_IMAGE\" alt=\"Testing image\"/>" -a "Hyprland keybind" -p -h "string:image-path:/var/lib/AccountsService/icons/$USER" -t 6000 -i "discord" -A "openImage=Profile image" -A "action2=Open the random image" -A "action3=Useless button"); [[ $ACTION == *openImage ]] && xdg-open "/var/lib/AccountsService/icons/$USER"; [[ $ACTION == *action2 ]] && xdg-open \"$RANDOM_IMAGE\"']=])) -- [hidden]
hl.bind("SUPER + ALT + f12", exec([=[bash -c 'RANDOM_IMAGE=$(find ~/Pictures -type f | grep -v -i "nipple" | grep -v -i "pussy" | shuf -n 1); ACTION=$(notify-send "Test notification" "This notification should contain a random image in your <b>Pictures</b> folder and <a href=\"https://discord.com/app\">Discord</a> <b>icon</b>.\n<i>Flick right to dismiss!</i>" -a "Discord (fake)" -p -h "string:image-path:$RANDOM_IMAGE" -t 6000 -i "discord" -A "openImage=Profile image" -A "action2=Useless button"); [[ $ACTION == *openImage ]] && xdg-open "/var/lib/AccountsService/icons/$USER"']=])) -- [hidden]
hl.bind("SUPER + ALT + Equal", exec([[notify-send "Urgent notification" "Ah hell no" -u critical -a 'Hyprland keybind']])) -- [hidden]

-- ##! Session
-- was: exec, hyprctl dispatch global quickshell:lock (old hyprctl dispatch syntax is gone in 0.57.1)
hl.bind("SUPER + ALT + L", global("quickshell:lock"), { description = "Lock" }) -- Lock (direct qs lock)
-- bindld = Super+Shift, L, Suspend system, exec, systemctl suspend || loginctl suspend # Sleep
-- bindl=,switch:on:Lid Switch, exec, systemctl suspend || loginctl suspend # [hidden] Suspend when laptop lid is closed, uncomment if for whatever reason it's not the default behavior
hl.bind("CTRL + SHIFT + ALT + SUPER + Delete", exec("systemctl poweroff || loginctl poweroff"), { description = "Shutdown" }) -- [hidden] Power off

-- ##! Screen
-- Zoom
hl.bind("SUPER + Minus", exec("~/.config/hypr/hyprland/scripts/zoom.sh decrease 0.3"), { repeating = true }) -- Zoom out
hl.bind("SUPER + Equal", exec("~/.config/hypr/hyprland/scripts/zoom.sh increase 0.3"), { repeating = true }) -- Zoom in
-- Zoom with keypad
hl.bind("SUPER + code:82", exec("qs -c " .. qsConfig .. " ipc call zoom zoomOut"), { repeating = true }) -- [hidden] Zoom out
hl.bind("SUPER + code:86", exec("qs -c " .. qsConfig .. " ipc call zoom zoomIn"), { repeating = true }) -- [hidden] Zoom in
hl.bind("SUPER + code:82", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || ~/.config/hypr/hyprland/scripts/zoom.sh decrease 0.1"), { repeating = true }) -- [hidden] Zoom out
hl.bind("SUPER + code:86", exec("qs -c " .. qsConfig .. " ipc call TEST_ALIVE || ~/.config/hypr/hyprland/scripts/zoom.sh increase 0.1"), { repeating = true }) -- [hidden] Zoom in

-- ##! Media
hl.bind("SUPER + SHIFT + N", exec([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]), { locked = true }) -- Next track
hl.bind("XF86AudioNext", exec([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]]), { locked = true }) -- [hidden]
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true }) -- [hidden]
hl.bind("SUPER + SHIFT + ALT + mouse:275", exec("playerctl previous")) -- [hidden]
hl.bind("SUPER + SHIFT + ALT + mouse:276", exec([[playerctl next || playerctl position `bc <<< "100 * $(playerctl metadata mpris:length) / 1000000 / 100"`]])) -- [hidden]
hl.bind("SUPER + SHIFT + B", exec("playerctl previous"), { locked = true }) -- Previous track
hl.bind("SUPER + SHIFT + P", exec("playerctl play-pause"), { locked = true }) -- Play/pause media
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true }) -- [hidden]
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true }) -- [hidden]

-- ##! Apps
-- bind = Super, Return, exec, ~/.config/hypr/hyprland/scripts/launch_first_available.sh "${TERMINAL}" "kitty -1" "foot" "alacritty" "wezterm" "konsole" "kgx" "uxterm" "xterm" # Terminal
hl.bind("SUPER + Return", exec("${TERMINAL}")) -- Terminal
-- bind = Super, E, exec, dolphin # File explorer
hl.bind("SUPER + Z", exec("zen-browser")) -- Browser
hl.bind("SUPER + SHIFT + O", exec([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "wps" "onlyoffice-desktopeditors" "libreoffice"]])) -- Office software
-- bind = Super, X, exec, ~/.config/hypr/hyprland/scripts/launch_first_available.sh "kate" "gnome-text-editor" "emacs" # Text editor
hl.bind("CTRL + SUPER + V", exec([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "pavucontrol-qt" "pavucontrol"]])) -- Volume mixer
hl.bind("SUPER + SHIFT + Slash", exec([[XDG_CURRENT_DESKTOP=gnome ~/.config/hypr/hyprland/scripts/launch_first_available.sh "qs -p ~/.config/quickshell/]] .. qsConfig .. [[/settings.qml" "systemsettings" "gnome-control-center" "better-control"]])) -- Settings app
hl.bind("CTRL + SHIFT + Escape", exec([[~/.config/hypr/hyprland/scripts/launch_first_available.sh "gnome-system-monitor" "plasma-systemmonitor --page-name Processes" "command -v btop && kitty -1 fish -c btop"]])) -- Task manager

-- Cursed stuff
-- ## Make window not amogus large
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.resize({ x = 640, y = 480 })) -- [hidden]

end) -- end of submap "global"

-- exec = hyprctl dispatch submap global # DO NOT REMOVE THIS OR YOU WON'T BE ABLE TO USE ANY KEYBIND
-- config.reloaded fires after every load (incl. the first); hyprland.start added as a safety net for first launch.
hl.on("config.reloaded", function() hl.dispatch(hl.dsp.submap("global")) end)
hl.on("hyprland.start", function() hl.dispatch(hl.dsp.submap("global")) end)
