#!/usr/bin/env bash

# Controls Hyprland's gamma, clamped between 0.3 and 3.0

# Get current gamma (reads from hyprctl output)
get_gamma() {
    local monitor="${1:-eDP-1}"
    hyprctl getoption -j output:$monitor:gamma | jq -r '.string' 2>/dev/null || echo "1.0"
}

# Clamp value between 0.3 and 3.0
clamp() {
    local val="$1"
    awk "BEGIN {
        v = $val;
        if (v < 0.3) v = 0.3;
        if (v > 3.0) v = 3.0;
        printf \"%.2f\", v;
    }"
}

# Set gamma for all monitors
# FIXME(Hyprland 0.57.1): per-output gamma is NOT settable any more.
#   `hyprctl keyword` was removed, and there is no Lua equivalent: HL.MonitorSpec in
#   /usr/share/hypr/stubs/hl.meta.lua has no gamma field, and `hyprctl getoption output:<mon>:gamma`
#   answers "no such option". Instead of silently doing nothing, fail loudly here.
#   Possible replacement: hyprsunset's IPC (`hyprctl hyprsunset gamma <percent>`), not wired up yet.
gamma_unsupported() {
    local msg="gamma: per-output gamma ($1) is not supported by Hyprland 0.57.1 (no hyprctl keyword, no Lua option)"
    echo "$0: $msg" >&2
    command -v notify-send >/dev/null && notify-send -u critical "Gamma unavailable" "$msg"
    exit 1
}
set_gamma() {
    local value="$1"
    local clamped=$(clamp "$value")
    gamma_unsupported "$clamped"
    # Old hyprlang-era calls, kept for reference (they now fail with "unknown request"):
    # hyprctl keyword output:eDP-1:gamma "$clamped"
    # hyprctl keyword output:DP-3:gamma "$clamped" 2>/dev/null
    # hyprctl keyword output:DP-4:gamma "$clamped" 2>/dev/null
    # hyprctl keyword output:HDMI-A-1:gamma "$clamped" 2>/dev/null
}

# Get current gamma (rough estimate from first available)
get_current() {
    for monitor in eDP-1 DP-3 DP-4 HDMI-A-1; do
        result=$(hyprctl getoption -j output:$monitor:gamma 2>/dev/null | jq -r '.string // empty')
        if [[ ! -z "$result" ]]; then
            echo "$result"
            return
        fi
    done
    echo "1.0"
}

case "$1" in
    reset)
        set_gamma 1.0
        ;;
    increase)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 increase STEP"
            exit 1
        fi
        current=$(get_current)
        new=$(awk "BEGIN { print $current + $2 }")
        set_gamma "$new"
        ;;
    decrease)
        if [[ -z "$2" ]]; then
            echo "Usage: $0 decrease STEP"
            exit 1
        fi
        current=$(get_current)
        new=$(awk "BEGIN { print $current - $2 }")
        set_gamma "$new"
        ;;
    *)
        echo "Usage: $0 {reset|increase STEP|decrease STEP}"
        exit 1
        ;;
esac
