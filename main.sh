#!/bin/bash
# Personal fork wrapper for end4's setup with custom packages (ov-* meta-packages)
# This script integrates end4's installer with personal customizations.

set -e

cd "$(dirname "$0")" || exit 1
export REPO_ROOT="$(pwd)"

# Source end4's helper functions
source ./sdata/lib/environment-variables.sh
source ./sdata/lib/functions.sh
source ./sdata/lib/package-installers.sh

# Source personal environment and functions
source ./.installation/scriptdata/environment-variables.sh
source ./.installation/scriptdata/functions.sh

prevent_sudo_or_root

################################################################################
# Personal customization functions
################################################################################

install_tmux_plugins() {
	printf "${STY_CYAN}[$0]: Installing tmux plugin manager (tpm)...${STY_RST}\n"
	local tpm_dir="$HOME/.tmux/plugins/tpm"

	if [ -d "$tpm_dir" ]; then
		read -p "Directory $tpm_dir already exists. Overwrite? (y/N): " choice
		case "$choice" in
		y | Y)
			v rm -rf "$tpm_dir"
			;;
		*)
			printf "${STY_YELLOW}[$0]: Skipping tpm installation.${STY_RST}\n"
			return 0
			;;
		esac
	fi

	v git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
	printf "${STY_CYAN}[$0]: tpm installed to $tpm_dir${STY_RST}\n"
}

install_qwerty_fr() {
	printf "${STY_CYAN}[$0]: Installing qwerty-fr keyboard layout...${STY_RST}\n"
	cd /
	v sudo wget https://github.com/qwerty-fr/qwerty-fr/releases/download/v0.7.3/qwerty-fr_0.7.3_linux.zip
	v sudo unzip -o qwerty-fr_0.7.3_linux.zip
	v sudo rm qwerty-fr_0.7.3_linux.zip
	cd "$REPO_ROOT" || exit
	printf "${STY_CYAN}[$0]: qwerty-fr installed.${STY_RST}\n"
}

install_npm_globals() {
	printf "${STY_CYAN}[$0]: Installing npm global packages for neovim...${STY_RST}\n"
	v sudo npm i -g tree-sitter-cli pyright
}

install_zsh_default() {
	printf "${STY_CYAN}[$0]: Setting ZSH as default shell...${STY_RST}\n"
	v chsh -s "$(which zsh)"
	printf "${STY_CYAN}[$0]: ZSH set as default shell.${STY_RST}\n"
}

install-local-pkgbuild() {
	local location=$1
	local installflags=$2

	x pushd "$location" || exit
	source ./PKGBUILD
	x yay -S $installflags --asdeps "${depends[@]}"
	x makepkg -Asi --noconfirm
	x popd || exit
}

install_ovsiankina_meta_packages() {
	printf "${STY_CYAN}[$0]: Installing personal meta-packages (ov-*)...${STY_RST}\n"

	local metapkgs=(
		./.installation/arch-packages/ovsiankina-meta-package/ov-system
		./.installation/arch-packages/ovsiankina-meta-package/ov-shell
		./.installation/arch-packages/ovsiankina-meta-package/ov-networking
		./.installation/arch-packages/ovsiankina-meta-package/ov-audio
		./.installation/arch-packages/ovsiankina-meta-package/ov-nvidia
		./.installation/arch-packages/ovsiankina-meta-package/ov-hyprland
		./.installation/arch-packages/ovsiankina-meta-package/ov-fonts-theme
		./.installation/arch-packages/ovsiankina-meta-package/ov-c-cpp-ecosystem
		./.installation/arch-packages/ovsiankina-meta-package/ov-python-ecosystem
		./.installation/arch-packages/ovsiankina-meta-package/ov-rust-ecosystem
		./.installation/arch-packages/ovsiankina-meta-package/ov-javascript-ecosystem
		./.installation/arch-packages/ovsiankina-meta-package/ov-devtools
		./.installation/arch-packages/ovsiankina-meta-package/ov-neovim
		./.installation/arch-packages/ovsiankina-meta-package/ov-desktop-apps
	)

	for pkg in "${metapkgs[@]}"; do
		if [ -d "$pkg" ]; then
			local installflags="--needed"
			v install-local-pkgbuild "$pkg" "$installflags"
		else
			printf "${STY_YELLOW}[$0]: Package $pkg not found, skipping.${STY_RST}\n"
		fi
	done
}

install_ovsiankina_aur_meta_packages() {
	printf "${STY_CYAN}[$0]: Installing personal AUR meta-packages (ov-*-AUR)...${STY_RST}\n"

	local aur_metapkgs=(
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-shell-AUR
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-hyprland-AUR
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-c-cpp-ecosystem-AUR
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-rust-ecosystem-AUR
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-devtools-AUR
		./.installation/arch-packages/ovsiankina-meta-package/ov-AUR/ov-desktop-apps-AUR
	)

	for pkg in "${aur_metapkgs[@]}"; do
		if [ -d "$pkg" ]; then
			local installflags="--needed"
			v install-local-pkgbuild "$pkg" "$installflags"
		else
			printf "${STY_YELLOW}[$0]: Package $pkg not found, skipping.${STY_RST}\n"
		fi
	done
}

symlink_with_stow() {
	printf "${STY_CYAN}[$0]: Creating symlinks with stow...${STY_RST}\n"
	x cd "$HOME/dotfiles" || exit
	v stow --adopt dots
	x cd "$HOME" || exit
}

################################################################################
# Main workflow
################################################################################

check_ssh_keys() {
	if [ ! -d "$HOME/.ssh" ] || [ -z "$(ls -A $HOME/.ssh/id_* 2>/dev/null)" ]; then
		printf "${STY_RED}${STY_BOLD}ERROR: SSH keys required in $HOME/.ssh/${STY_RST}\n"
		printf "${STY_RED}This fork has private git submodules that need SSH authentication.${STY_RST}\n"
		exit 1
	fi
}

main() {
	printf "\n${STY_BOLD}${STY_CYAN}===== PERSONAL FORK SETUP (end4 + ov-*) =====${STY_RST}\n\n"

	check_ssh_keys

	# Ensure all git submodules are initialized (each independently, so one failure doesn't block the rest)
	printf "${STY_CYAN}[$0]: Initializing git submodules...${STY_RST}\n"
	git submodule init
	git submodule foreach --recursive 'git submodule update --init || true'
	git submodule update --init --recursive || printf "${STY_YELLOW}[$0]: Some submodules failed to initialize. Continuing anyway.${STY_RST}\n"

	# Step 1: Run end4's full setup
	printf "${STY_BOLD}${STY_CYAN}[1/3] Running end4 installer...${STY_RST}\n"
	SKIP_ALLFILES=true v ./setup install

	# Step 2: Install personal packages and additional setup
	printf "\n${STY_BOLD}${STY_CYAN}[2/3] Installing personal packages and configurations...${STY_RST}\n"
	install_ovsiankina_meta_packages
	install_ovsiankina_aur_meta_packages
	v install_tmux_plugins
	v install_qwerty_fr
	v install_npm_globals
	v install_zsh_default

	# Clean up directories that end4's installer copied as real files,
	# so stow can replace them with symlinks to the repo (which has
	# properly checked-out submodules like shapes/).
	printf "${STY_CYAN}[$0]: Cleaning copied configs so stow can symlink from repo...${STY_RST}\n"
	rm -rf "$HOME/.config/quickshell"
	rm -rf "$HOME/.config/hypr"

	# Step 3: Stow dotfiles
	printf "\n${STY_BOLD}${STY_CYAN}[3/3] Creating dotfile symlinks...${STY_RST}\n"
	v symlink_with_stow

	printf "\n${STY_BOLD}${STY_CYAN}===== SETUP COMPLETE =====${STY_RST}\n"
	printf "${STY_CYAN}Next steps:${STY_RST}\n"
	printf "  1. Source your shell: zsh\n"
	printf "  2. Verify upstream remote: git remote -v\n"
	printf "  3. Try Hyprland: hyprctl reload\n"
}

main "$@"
