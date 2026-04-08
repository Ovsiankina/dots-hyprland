#!/usr/bin/env bash

# Enable this with cronjob !

# ```bash
# crontab -e
# */25 * * * * path/to/scripts/prevent-yt-overuse.sh
# ```

detectYoutube(){
    activewindow=$(hyprctl activewindow)
    matches=$(echo "$activewindow" | grep -E 'YouTube')
}

activewindow=''
matches=''

detectYoutube 

# Abort if Youtube is not detected
if [[ -z "$matches" ]]; then
  notify-send "No YT window detected"
  exit 0
fi

echo "⚡ Found the following YouTube window(s):"
echo "$matches"

notify-send "YouTube detected. 2m before browser shutdown !"

# If YT is detected again in 2m, browser is shutdown by force
sleep 2m
detectYoutube 

pid=$(echo "$activewindow" | grep -oP 'pid:\s*\K[0-9]+')

# Abort if Youtube is not longer detected
if [[ -z "$matches" ]]; then
    notify-send "YouTube no longer active. Browser shutdown prevented !"
    exit 0
fi

# Shutdown browser by it's PID
kill "$pid" \
  && notify-send "   • Successfully sent SIGTERM to $pid." \
  || notify-send "   ⚠ Failed to kill $pid (insufficient perms?)."
