-- Shell overrides bridge.
-- The quickshell "illogical-impulse" shell (services/HyprlandConfig.qml) writes flat
-- hyprlang lines such as `general:gaps_in = 0` or `decoration:screen_shader = /path`
-- into hyprland/shellOverrides/main.conf (game-mode toggle, anti-flashbang shader, ...).
-- Hyprland no longer reads hyprlang here, so this module parses that file and applies
-- every line through hl.config(). It must stay LAST in hyprland.lua so it overrides
-- the regular settings.

local path = os.getenv("HOME") .. "/.config/hypr/hyprland/shellOverrides/main.conf"

local function coerce(raw)
    if raw == "true" then return true end
    if raw == "false" then return false end
    local n = tonumber(raw)
    if n ~= nil then return n end
    return raw
end

local function apply_line(line)
    -- strip comments and whitespace
    line = line:gsub("#.*$", ""):gsub("^%s+", ""):gsub("%s+$", "")
    if line == "" then return end
    local key, value = line:match("^([%w_:%.]+)%s*=%s*(.-)$")
    if not key then return end
    value = coerce(value)

    -- "a:b:c" -> { a = { b = { c = value } } }
    local parts = {}
    for part in key:gmatch("[^:]+") do parts[#parts + 1] = part end
    local tbl, cursor = {}, nil
    cursor = tbl
    for i = 1, #parts - 1 do
        cursor[parts[i]] = {}
        cursor = cursor[parts[i]]
    end
    cursor[parts[#parts]] = value
    hl.config(tbl)
end

local f = io.open(path, "r")
if f then
    for line in f:lines() do apply_line(line) end
    f:close()
end

-- Hyprland only watches hyprland.lua and the files it `require`s, not files opened with io.open,
-- so edits the shell makes to main.conf would otherwise sit unnoticed until the next reload.
-- Poll the file (it is a few lines long) and reload the config when its content changes.
-- Timers are discarded on every reload, so this one is recreated each time this module runs.
local function read_all()
    local fh = io.open(path, "r")
    if not fh then return "" end
    local content = fh:read("a") or ""
    fh:close()
    return content
end

local last = read_all()
local watcher = nil
local function start_watcher()
    if watcher then return end
    watcher = hl.timer(function()
        local now = read_all()
        if now ~= last then
            last = now
            hl.dispatch(hl.dsp.reload_config())
        end
    end, { timeout = 1000, type = "repeat" })
end

-- `Hyprland --verify-config` has no event loop and crashes on timers; it also has no monitors.
-- So only start the watcher once a monitor exists (immediately on reload, or on the first
-- monitor.added event during startup).
if #hl.get_monitors({ all = true }) > 0 then
    start_watcher()
else
    hl.on("monitor.added", start_watcher)
end
