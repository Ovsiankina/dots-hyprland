#!/bin/bash

# Hyprland Window Swap Script
# Swaps the active workspaces between two monitors.
# Hyprland 0.57+: `hyprctl dispatch` takes a Lua expression, so we use the native
# hl.dsp.workspace.swap_monitors dispatcher (the old `swapactiveworkspaces`).

readarray -t monitors < <(hyprctl monitors -j | jq -r '.[].name')

if [ ${#monitors[@]} -ne 2 ]; then
    notify-send "swap-windows" "Requires exactly 2 monitors, found ${#monitors[@]}."
    exit 1
fi

if ! out=$(hyprctl dispatch "hl.dsp.workspace.swap_monitors({ monitor1 = \"${monitors[0]}\", monitor2 = \"${monitors[1]}\" })" 2>&1) \
    || [[ "$out" == *rror* ]]; then
    notify-send "swap-windows" "Swap failed: $out"
    exit 1
fi
