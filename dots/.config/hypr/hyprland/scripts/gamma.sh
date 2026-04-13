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
set_gamma() {
    local value="$1"
    local clamped=$(clamp "$value")
    # Apply to primary monitor
    hyprctl keyword output:eDP-1:gamma "$clamped"
    # Apply to other monitors if they exist
    hyprctl keyword output:DP-3:gamma "$clamped" 2>/dev/null
    hyprctl keyword output:DP-4:gamma "$clamped" 2>/dev/null
    hyprctl keyword output:HDMI-A-1:gamma "$clamped" 2>/dev/null
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
