#!/bin/bash
# end4-sync.sh — Copy resolved files from your end-4 fork into your dotfiles repo.
# You handle fetch/merge manually in the fork. This just copies the result.
#
# Usage:
#   ./end4-sync.sh              # Interactive: show what will change, then copy
#   ./end4-sync.sh --force      # Copy without confirmation
#   ./end4-sync.sh --diff-only  # Just show what would change

set -euo pipefail

########################################
# Config
########################################
END4_CLONE_DIR="${END4_CLONE_DIR:-$HOME/.cache/dots-hyprland}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# source (relative to clone) : destination (relative to dotfiles)
SYNC_TARGETS=(
	"dots/.config/quickshell/ii/:.config/quickshell/"
	"dots/.config/matugen/:.config/matugen/"
	"dots/.config/kde-material-you-colors/:.config/kde-material-you-colors/"
	"dots/.config/fuzzel/:.config/fuzzel/"
	"dots/.config/mpv/:.config/mpv/"
	"dots/.config/wlogout/:.config/wlogout/"
	"dots/.config/dolphinrc:.config/dolphinrc"
	"dots/.config/darklyrc:.config/darklyrc"
	"sdata/uv/:installation/sdata/uv/"
)

########################################
# Parse args
########################################
FORCE=false
DIFF_ONLY=false

for arg in "$@"; do
	case $arg in
	--force) FORCE=true ;;
	--diff-only) DIFF_ONLY=true ;;
	-h | --help)
		echo "Usage: $0 [--force|--diff-only]"
		exit 0
		;;
	*)
		echo "Unknown arg: $arg"
		exit 1
		;;
	esac
done

########################################
# Preflight
########################################
if [ ! -d "$END4_CLONE_DIR/.git" ]; then
	echo "[end4-sync]: Fork not found at $END4_CLONE_DIR"
	exit 1
fi

########################################
# Show what would change
########################################
show_diff() {
	local has_diff=false

	for target in "${SYNC_TARGETS[@]}"; do
		local src="${target%%:*}"
		local dst="${target##*:}"
		local full_src="$END4_CLONE_DIR/$src"
		local full_dst="$DOTFILES_DIR/$dst"

		[ ! -e "$full_src" ] && continue

		if [ -d "$full_src" ]; then
			if [ ! -d "$full_dst" ]; then
				echo -e "\e[33m$dst\e[0m \e[31m(new — will be created)\e[0m"
				has_diff=true
			else
				local changes
				changes=$(diff -rq "$full_src" "$full_dst" 2>/dev/null) || true
				if [ -n "$changes" ]; then
					echo -e "\e[33m$dst\e[0m"
					echo "$changes" | head -20
					has_diff=true
				fi
			fi
		else
			if [ ! -f "$full_dst" ]; then
				echo -e "\e[33m$dst\e[0m \e[31m(new — will be copied)\e[0m"
				has_diff=true
			elif ! cmp -s "$full_src" "$full_dst"; then
				echo -e "\e[33m$dst\e[0m (modified)"
				has_diff=true
			fi
		fi
	done

	if ! $has_diff; then
		echo "Nothing to sync. Dotfiles already match the fork."
		return 1
	fi
	return 0
}

########################################
# Copy everything
########################################
do_sync() {
	for target in "${SYNC_TARGETS[@]}"; do
		local src="${target%%:*}"
		local dst="${target##*:}"
		local full_src="$END4_CLONE_DIR/$src"
		local full_dst="$DOTFILES_DIR/$dst"

		[ ! -e "$full_src" ] && continue

		if [ -d "$full_src" ]; then
			rm -rf "$full_dst"
			mkdir -p "$full_dst"
			echo "  rsync $src → $dst"
			rsync -a "$full_src/" "$full_dst/"
		else
			mkdir -p "$(dirname "$full_dst")"
			echo "  cp $src → $dst"
			cp "$full_src" "$full_dst"
		fi
	done

	echo "Done."
}

########################################
# Main
########################################
if ! show_diff; then
	exit 0
fi

if $DIFF_ONLY; then
	exit 0
fi

if ! $FORCE; then
	read -p "Sync? [y/N]: " answer
	[[ "$answer" =~ ^[yY]$ ]] || exit 0
fi

do_sync
