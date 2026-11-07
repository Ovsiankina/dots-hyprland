#!/usr/bin/env bash
## Hyprland 0.57.1: `hyprctl dispatch` takes a Lua expression, e.g.
##   hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
## The old `hyprctl dispatch <dispatcher> <arg>` form errors, so map the old dispatcher names to Lua.
curr_workspace="$(hyprctl activeworkspace -j | jq -r ".id")"
dispatcher="$1"
shift ## The target is now in $1, not $2

if [[ -z "${dispatcher}" || "${dispatcher}" == "--help" || "${dispatcher}" == "-h" || -z "$1" ]]; then
  echo "Usage: $0 <dispatcher> <target>"
  exit 1
fi

## Turn a workspace target into a Lua literal: plain integers stay numbers, everything else
## (r+1, -1, special, name:foo, ...) becomes a quoted, escaped Lua string.
lua_target() {
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    printf '%s' "$1"
  else
    local s="${1//\\/\\\\}"
    s="${s//\"/\\\"}"
    printf '"%s"' "$s"
  fi
}

## Dispatch the old-style <dispatcher> <target> through the Lua API.
dispatch() {
  local target
  target="$(lua_target "$2")"
  case "$1" in
    workspace)
      hyprctl dispatch "hl.dsp.focus({ workspace = ${target} })" ;;
    movetoworkspacesilent)
      ## `follow = false` is the Lua equivalent of movetoworkspacesilent (`silent` is not a known key).
      hyprctl dispatch "hl.dsp.window.move({ workspace = ${target}, follow = false })" ;;
    movetoworkspace)
      hyprctl dispatch "hl.dsp.window.move({ workspace = ${target} })" ;;
    *)
      echo "$0: unsupported dispatcher '$1' (supported: workspace, movetoworkspace, movetoworkspacesilent)" >&2
      return 1 ;;
  esac
}

if [[ "$1" == *"+"* || "$1" == *"-"* ]]; then ## Is this something like r+1 or -1?
  dispatch "${dispatcher}" "$1" ## $1 = workspace id since we shifted earlier.
elif [[ "$1" =~ ^[0-9]+$ ]]; then ## Is this just a number?
  target_workspace=$((((curr_workspace - 1) / 10 ) * 10 + $1))
  dispatch "${dispatcher}" "${target_workspace}"
else
  dispatch "${dispatcher}" "$1" ## In case the target in a string, required for special workspaces.
  exit 1
fi
