-- Ported from hyprland/env.conf
-- hl.env(name, value[, dbus]) replaces hyprlang `env = NAME,value`.

-- ############ Wayland #############
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ######## Applications #########
-- hyprlang expanded $HOME here; Lua has to do it explicitly.
hl.env("XDG_DATA_DIRS", os.getenv("HOME") .. "/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share")

-- ############ Themes #############
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("XDG_MENU_PREFIX", "plasma-")

-- ######## Virtual envrionment #########
-- Kept as the literal "~/..." string, exactly as in env.conf (hyprlang did not expand `~`
-- either); the consumers (quickshell scripts) expand it themselves.
hl.env("ILLOGICAL_IMPULSE_VIRTUAL_ENV", "~/.local/state/quickshell/.venv")

-- ######## Terminal application #########
hl.env("TERMINAL", "kitty -1")
