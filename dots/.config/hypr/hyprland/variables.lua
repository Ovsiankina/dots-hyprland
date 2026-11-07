-- Ported from hyprland/variables.conf (+ `$qsConfig = ii` from hyprland.conf)
-- Lua has no hyprlang `$variables`: this module returns a table of shared values.
-- Usage in other modules: local vars = require("hyprland.variables")  ->  vars.qsConfig

local vars = {
    -- Quickshell config name (was `$qsConfig = ii` in hyprland.conf)
    qsConfig = "ii",

    -- ── Apps ────────────────────────────────────────────────────────────────────
    -- menu     = "wofi --show drun --location=center",
    -- run      = "wofi --show run --location=top --width=100%",
    -- terminal = "kitty --config " .. os.getenv("HOME") .. "/.config/kitty/kitty.conf",
}

return vars
