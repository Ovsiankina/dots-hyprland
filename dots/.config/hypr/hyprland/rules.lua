-- Window rules and layer rules (ported from hyprland/rules.conf)

-- ######## Window rules ########

-- Disable blur for xwayland context menus
hl.window_rule({
    name = "no-blur-xwayland",
    match = { class = "^()$", title = "^()$" },
    no_blur = true,
})

-- Disable blur for every window
hl.window_rule({
    name = "no-blur-global",
    match = { class = ".*" },
    no_blur = true,
})

-- Floating - File dialogs
hl.window_rule({
    name = "float-open-file",
    match = { title = "^(Open File)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-select-file",
    match = { title = "^(Select a File)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-choose-wallpaper",
    match = { title = "^(Choose wallpaper)(.*)$" },
    center = true,
    float = true,
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    name = "float-open-folder",
    match = { title = "^(Open Folder)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-save-as",
    match = { title = "^(Save As)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-library",
    match = { title = "^(Library)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-file-upload",
    match = { title = "^(File Upload)(.*)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-save-dialog",
    match = { title = "^(.*)(wants to save)$" },
    center = true,
    float = true,
})

hl.window_rule({
    name = "float-open-dialog",
    match = { title = "^(.*)(wants to open)$" },
    center = true,
    float = true,
})

-- Floating - Applications
hl.window_rule({
    name = "float-blueberry",
    match = { class = [[^(blueberry\.py)$]] },
    float = true,
})

hl.window_rule({
    name = "float-guifetch",
    match = { class = "^(guifetch)$" },
    float = true,
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
    center = true,
})

hl.window_rule({
    name = "float-pavucontrol-freedesktop",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
    center = true,
})

hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
    center = true,
})

hl.window_rule({
    name = "float-plasma-windowed",
    match = { class = ".*plasmawindowed.*" },
    float = true,
})

hl.window_rule({
    name = "float-kcm",
    match = { class = "kcm_.*" },
    float = true,
})

hl.window_rule({
    name = "float-bluedevil-wizard",
    match = { class = ".*bluedevilwizard" },
    float = true,
})

hl.window_rule({
    name = "float-welcome",
    match = { title = ".*Welcome" },
    float = true,
})

hl.window_rule({
    name = "float-illogical-impulse-settings",
    match = { title = "^(illogical-impulse Settings)$" },
    float = true,
})

hl.window_rule({
    name = "float-shell-conflicts",
    match = { title = ".*Shell conflicts.*" },
    float = true,
})

hl.window_rule({
    name = "float-kde-portal",
    match = { class = "org.freedesktop.impl.portal.desktop.kde" },
    float = true,
    size = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({
    name = "float-zotero",
    match = { class = "^(Zotero)$" },
    float = true,
    size = "(monitor_w*.45) (monitor_h*.45)",
})

-- Move
-- kde-material-you-colors spawns a window when changing dark/light theme. This is to make sure it doesn't interfere at all.
hl.window_rule({
    name = "move-plasma-changeicons",
    match = { class = "^(plasma-changeicons)$" },
    float = true,
    no_initial_focus = true,
    move = "999999 999999",
})

-- stupid dolphin copy
hl.window_rule({
    name = "move-dolphin-copy",
    match = { title = "^(Copying — Dolphin)$" },
    move = "40 80",
})

-- Tiling
hl.window_rule({
    name = "tile-warp",
    match = { class = [[^dev\.warp\.Warp$]] },
    tile = true,
})

-- Picture-in-Picture
hl.window_rule({
    name = "float-pip",
    match = { title = [[^([Pp]icture[-\s]?[Ii]n[-\s]?[Pp]icture)(.*)$]] },
    float = true,
    keep_aspect_ratio = true,
    move = "(monitor_w*.73) (monitor_h*.72)",
    size = "(monitor_w*.25) (monitor_h*.25)",
    pin = true,
})

-- Tearing - Games
hl.window_rule({
    name = "immediate-exe",
    match = { title = [[.*\.exe]], fullscreen = true },
    immediate = true,
})

hl.window_rule({
    name = "immediate-minecraft",
    match = { title = ".*minecraft.*" },
    immediate = true,
})

hl.window_rule({
    name = "immediate-steam-app",
    match = { class = "^(steam_app).*" },
    immediate = true,
})

-- Fix Jetbrain IDEs focus/rerendering problem
hl.window_rule({
    name = "jetbrains-no-initial-focus",
    match = { class = "^jetbrains-.*$", float = true, title = [[^$|^\s$|^win\d+$]] },
    no_initial_focus = true,
})

-- No shadow for tiled windows (matches windows that are not floating).
hl.window_rule({
    name = "no-shadow-tiled",
    match = { float = false },
    no_shadow = true,
})

-- ######## Layer rules ########

-- Global layer rules
hl.layer_rule({
    name = "xray-all-namespaces",
    match = { namespace = ".*" },
    xray = true,
})

hl.layer_rule({
    name = "noanim-walker",
    match = { namespace = "walker" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-selection",
    match = { namespace = "selection" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-overview",
    match = { namespace = "overview" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-anyrun",
    match = { namespace = "anyrun" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-indicator",
    match = { namespace = "indicator.*" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-osk",
    match = { namespace = "osk" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-hyprpicker",
    match = { namespace = "hyprpicker" },
    no_anim = true,
})

hl.layer_rule({
    name = "noanim-noanim",
    match = { namespace = "noanim" },
    no_anim = true,
})

hl.layer_rule({
    name = "blur-gtk-layer-shell",
    match = { namespace = "gtk-layer-shell" },
    blur = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "blur-launcher",
    match = { namespace = "launcher" },
    blur = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "blur-notifications",
    match = { namespace = "notifications" },
    blur = true,
    ignore_alpha = 0.69,
})

hl.layer_rule({
    name = "blur-logout-dialog",
    match = { namespace = "logout_dialog" },
    blur = true,
})

-- AGS layer rules
hl.layer_rule({
    name = "anim-sideleft",
    match = { namespace = "sideleft.*" },
    animation = "slide left",
})

hl.layer_rule({
    name = "anim-sideright",
    match = { namespace = "sideright.*" },
    animation = "slide right",
})

hl.layer_rule({
    name = "blur-session",
    match = { namespace = "session[0-9]*" },
    blur = true,
})

hl.layer_rule({
    name = "blur-bar-all",
    match = { namespace = "bar[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-barcorner",
    match = { namespace = "barcorner.*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-dock-all",
    match = { namespace = "dock[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-indicator-all",
    match = { namespace = "indicator.*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-overview-all",
    match = { namespace = "overview[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-cheatsheet-all",
    match = { namespace = "cheatsheet[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-sideright-all",
    match = { namespace = "sideright[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-sideleft-all",
    match = { namespace = "sideleft[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

hl.layer_rule({
    name = "blur-osk-all",
    match = { namespace = "osk[0-9]*" },
    blur = true,
    ignore_alpha = 0.6,
})

-- Quickshell: illogical-impulse
hl.layer_rule({
    name = "qs-blur-popups",
    match = { namespace = "quickshell:.*" },
    blur_popups = true,
    blur = true,
    ignore_alpha = 0.79,
})

hl.layer_rule({
    name = "qs-bar-animation",
    match = { namespace = "quickshell:bar" },
    animation = "slide",
})

hl.layer_rule({
    name = "qs-action-center-noanim",
    match = { namespace = "quickshell:actionCenter" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-cheatsheet-animation",
    match = { namespace = "quickshell:cheatsheet" },
    animation = "slide bottom",
})

hl.layer_rule({
    name = "qs-dock-animation",
    match = { namespace = "quickshell:dock" },
    animation = "slide bottom",
})

hl.layer_rule({
    name = "qs-screen-corners-animation",
    match = { namespace = "quickshell:screenCorners" },
    animation = "popin 120%",
})

hl.layer_rule({
    name = "qs-lock-window-pusher-noanim",
    match = { namespace = "quickshell:lockWindowPusher" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-notification-popup-animation",
    match = { namespace = "quickshell:notificationPopup" },
    animation = "fade",
})

hl.layer_rule({
    name = "qs-overlay-noanim",
    match = { namespace = "quickshell:overlay" },
    no_anim = true,
    ignore_alpha = 1,
})

hl.layer_rule({
    name = "qs-overview-noanim",
    match = { namespace = "quickshell:overview" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-osk-animation",
    match = { namespace = "quickshell:osk" },
    animation = "slide bottom",
})

hl.layer_rule({
    name = "qs-polkit-noanim",
    match = { namespace = "quickshell:polkit" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-popup-xray-off",
    match = { namespace = "quickshell:popup" },
    xray = false,
    ignore_alpha = 1,
})

hl.layer_rule({
    name = "qs-media-controls-alpha",
    match = { namespace = "quickshell:mediaControls" },
    ignore_alpha = 1,
})

hl.layer_rule({
    name = "qs-reload-popup-animation",
    match = { namespace = "quickshell:reloadPopup" },
    animation = "slide",
})

hl.layer_rule({
    name = "qs-region-selector-noanim",
    match = { namespace = "quickshell:regionSelector" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-screenshot-noanim",
    match = { namespace = "quickshell:screenshot" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-session-blur",
    match = { namespace = "quickshell:session" },
    blur = true,
    no_anim = true,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "qs-sidebar-right-animation",
    match = { namespace = "quickshell:sidebarRight" },
    animation = "slide right",
})

hl.layer_rule({
    name = "qs-sidebar-left-animation",
    match = { namespace = "quickshell:sidebarLeft" },
    animation = "slide left",
})

hl.layer_rule({
    name = "qs-vertical-bar-animation",
    match = { namespace = "quickshell:verticalBar" },
    animation = "slide",
})

hl.layer_rule({
    name = "qs-osk-order",
    match = { namespace = "quickshell:osk" },
    order = -1,
})

-- Quickshell: waffles
hl.layer_rule({
    name = "qs-wallpaper-selector-animation",
    match = { namespace = "quickshell:wallpaperSelector" },
    animation = "slide top",
})

hl.layer_rule({
    name = "qs-notification-center-noanim",
    match = { namespace = "quickshell:wNotificationCenter" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-on-screen-display-noanim",
    match = { namespace = "quickshell:wOnScreenDisplay" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-start-menu-noanim",
    match = { namespace = "quickshell:wStartMenu" },
    no_anim = true,
})

hl.layer_rule({
    name = "qs-task-view-alpha",
    match = { namespace = "quickshell:wTaskView" },
    ignore_alpha = 0,
    no_anim = true,
})

-- Launchers need to be FAST
hl.layer_rule({
    name = "noanim-gtk4-layer-shell",
    match = { namespace = "gtk4-layer-shell" },
    no_anim = true,
})

-- ──────────────────────────────────────────────────────────────────
-- ──────────── User Customizations ─────────────────────────────────
-- ──────────────────────────────────────────────────────────────────

-- General glassmorphism
hl.window_rule({
    name = "spotify-wofi-opacity",
    match = { title = "^(Spotify.*|wofi.*)$" },
    opacity = "0.8",
})

hl.window_rule({
    name = "zen-browser-opacity",
    match = { title = "^(Zen Browser)$" },
    opacity = "1",
})

-- ── kitty ───────────────────────────────────────────────────────

-- Kitty opacity: active = 0.95, inactive = 0.85
hl.window_rule({
    name = "kitty-opacity-focused",
    match = { class = "^(kitty)$" },
    opacity = "1",
})

hl.window_rule({
    name = "float-kitty-window",
    match = { title = "^(float)$" },
    float = true,
    size = "800 500",
    center = true, -- was `move = center` (invalid in Lua)
})

hl.window_rule({
    name = "pinta",
    match = { class = "^(com.github.PintaProject.Pinta)$" },
    float = true,
})

-- Pinned windows border color (ported from the last line of hyprland/colors.conf:
-- `windowrule = border_color rgba(ffffffAA) rgba(ffffff77), match:pin 1`)
hl.window_rule({
    name = "pinned-border-color",
    match = { pin = true },
    border_color = "rgba(ffffffAA) rgba(ffffff77)",
})
