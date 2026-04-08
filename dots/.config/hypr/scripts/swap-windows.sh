#!/bin/bash

# Hyprland Window Swap Script
# Swaps windows between two monitors

# Get monitor information and active workspaces
monitors_info=$(hyprctl monitors -j)
workspaces_info=$(hyprctl workspaces -j)

# Extract monitor names and their active workspaces
monitor_data=$(echo "$monitors_info" | jq -r '.[] | "\(.name):\(.activeWorkspace.id)"')

# Convert to array
readarray -t monitor_array <<< "$monitor_data"

# Check if we have exactly 2 monitors
if [ ${#monitor_array[@]} -ne 2 ]; then
    echo "Error: This script requires exactly 2 monitors. Found ${#monitor_array[@]} monitors."
    exit 1
fi

# Parse monitor data
monitor1_name=$(echo "${monitor_array[0]}" | cut -d':' -f1)
workspace1_id=$(echo "${monitor_array[0]}" | cut -d':' -f2)

monitor2_name=$(echo "${monitor_array[1]}" | cut -d':' -f1)
workspace2_id=$(echo "${monitor_array[1]}" | cut -d':' -f2)

echo "Monitor 1: $monitor1_name (Workspace $workspace1_id)"
echo "Monitor 2: $monitor2_name (Workspace $workspace2_id)"

echo "Swapping workspaces between monitors..."

# Move workspaces to swap monitors
echo "Moving workspace $workspace1_id to monitor $monitor2_name"
hyprctl dispatch moveworkspacetomonitor "$workspace1_id $monitor2_name"

echo "Moving workspace $workspace2_id to monitor $monitor1_name"
hyprctl dispatch moveworkspacetomonitor "$workspace2_id $monitor1_name"

echo "Workspace swap completed!"

# Optional: Focus on the first monitor to show the change
# TODO: fix focus problem that forces me to use mouse to elect between the two workspaces
hyprctl dispatch workspace "$workspace1_id"
hyprctl dispatch workspace "$workspace2_id"
