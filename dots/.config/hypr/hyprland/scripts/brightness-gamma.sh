#!/usr/bin/env bash

# Brightness-gamma control: when brightness reaches 0, further decreases adjust gamma
# Usage: brightness-gamma.sh {up|down}

STEP_BRIGHTNESS=5
STEP_GAMMA=0.1

get_brightness() {
    brightnessctl get 2>/dev/null || echo "100"
}

get_max_brightness() {
    brightnessctl max 2>/dev/null || echo "100"
}

get_gamma() {
    for monitor in eDP-1 DP-3 DP-4 HDMI-A-1; do
        result=$(hyprctl getoption -j output:$monitor:gamma 2>/dev/null | jq -r '.string // empty')
        if [[ ! -z "$result" ]] && [[ "$result" != "1.0" ]]; then
            echo "$result"
            return
        fi
    done
    echo "1.0"
}

clamp_gamma() {
    local val="$1"
    awk "BEGIN {
        v = $val;
        if (v < 0.3) v = 0.3;
        if (v > 3.0) v = 3.0;
        printf \"%.2f\", v;
    }"
}

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
    gamma_unsupported "$value"
    # Old hyprlang-era calls, kept for reference (they now fail with "unknown request"):
    # hyprctl keyword output:eDP-1:gamma "$value"
    # hyprctl keyword output:DP-3:gamma "$value" 2>/dev/null
    # hyprctl keyword output:DP-4:gamma "$value" 2>/dev/null
    # hyprctl keyword output:HDMI-A-1:gamma "$value" 2>/dev/null
}

case "$1" in
    up)
        # Always increase brightness first if not at max
        current=$(get_brightness)
        max=$(get_max_brightness)
        if [[ $current -lt $max ]]; then
            brightnessctl s "$STEP_BRIGHTNESS%+"
        else
            # At max brightness, increase gamma
            current_gamma=$(get_gamma)
            new_gamma=$(awk "BEGIN { printf \"%.2f\", $current_gamma + $STEP_GAMMA }")
            new_gamma=$(clamp_gamma "$new_gamma")
            set_gamma "$new_gamma"
        fi
        ;;
    down)
        # If at min brightness, decrease gamma; otherwise decrease brightness
        current=$(get_brightness)
        if [[ $current -le 0 ]]; then
            current_gamma=$(get_gamma)
            new_gamma=$(awk "BEGIN { printf \"%.2f\", $current_gamma - $STEP_GAMMA }")
            new_gamma=$(clamp_gamma "$new_gamma")
            set_gamma "$new_gamma"
        else
            brightnessctl s "$STEP_BRIGHTNESS%-"
        fi
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
