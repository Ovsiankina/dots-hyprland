#!/bin/bash
cd "$(dirname "$0")"
export base="$(pwd)"

source ./scriptdata/environment-variables.sh
source ./scriptdata/functions.sh
source ./scriptdata/installers.sh
source ./scriptdata/options.sh

SCRIPT_DIR="$HOME/dotfiles/installation"

check_distro() {
	if ! command -v pacman >/dev/null 2>&1; then
		printf "\e[31m[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...\e[0m\n"
		exit 1
	fi
}

startask() {
	printf "\e[34m[$0]: ===Installation helper ===\n"
	printf 'Courtesy to "illogical-impulse" ! https://github.com/end-4/dots-hyprland\n'
	printf '\n'
	printf 'WARN: This script only works for ArchLinux and Arch-based distros.\n'
	printf "\e[31m"

	printf "Would you like to create a backup for \"$XDG_CONFIG_HOME\" and \"$HOME/.local/\" folders?\n[y/N]: "
	read -p " " backup_confirm
	case $backup_confirm in
	[yY][eE][sS] | [yY])
		v backup_configs
		;;
	*)
		echo "Skipping backup..."
		;;
	esac

	printf '\n'
	printf 'Do you want to confirm every time before a command executes?\n'
	printf '  y = Yes, ask me before executing each of them. (DEFAULT)\n'
	printf '  n = No, just execute them automatically.\n'
	printf '  a = Abort.\n'
	read -p "====> " p
	case $p in
	n) ask=false ;;
	a) exit 1 ;;
	*) ask=true ;;
	esac
}

ask() {
	case $ask in
	false) sleep 0 ;;
	*) startask ;;
	esac
	set -e
}

update_sys() {
	case $SKIP_SYSUPDATE in
	true) sleep 0 ;;
	*) v sudo pacman -Syu ;;
	esac
}

install_yay() {
	if ! command -v yay >/dev/null 2>&1; then
		echo -e "\e[33m[$0]: \"yay\" not found.\e[0m"
		showfun install-yay
		v install-yay
	fi
}

install_tmux_plugins() {
	echo "Installing tmux addons ..."
	TPM_DIR="$HOME/.tmux/plugins/tpm"

	if [ -d "$TPM_DIR" ]; then
		read -p "Directory $TPM_DIR already exists. Do you want to overwrite it? (y/N): " choice
		case "$choice" in
		y | Y)
			v rm -rf "$TPM_DIR"
			;;
		*)
			echo "Skipping tmux plugin installation."
			return 0
			;;
		esac
	fi

	v git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"

	echo "Installing npm global packages for neovim ..."
	v sudo npm i -g tree-sitter-cli pyright
}

install_qwerty_fr() {
	cd /
	v sudo wget https://github.com/qwerty-fr/qwerty-fr/releases/download/v0.7.3/qwerty-fr_0.7.3_linux.zip
	v sudo unzip qwerty-fr_0.7.3_linux.zip
	v sudo rm qwerty-fr_0.7.3_linux.zip
	x cd "$base"
}

install-local-pkgbuild() {
	local location=$1
	local installflags=$2

	x pushd $location
	source ./PKGBUILD
	x yay -S $installflags --asdeps "${depends[@]}"
	x makepkg -Asi --noconfirm
	x popd
}

install_ovsiankina_meta_packages() {
	# BUG: when a package failed to download/install, reapeating causes the script
	# to repeat the whole `install_ovsiankina_meta_packages()' function and not
	# just the failed "makepkg"

	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-system)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-shell)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-networking/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-audio/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-nvidia/)

	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-hyprland/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-fonts-theme/)

	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-c-cpp-ecosystem/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-python-ecosystem/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-rust-ecosystem/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-javascript-ecosystem/)

	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-devtools/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-neovim/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-desktop-apps/)

	for i in "${metapkgs[@]}"; do
		metainstallflags="--needed"
		$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
		v install-local-pkgbuild "$i" "$metainstallflags"
	done
}

install_ovsiankina_AUR_meta_packages() {
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-shell-AUR/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-hyprland-AUR/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-c-cpp-ecosystem-AUR/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-rust-ecosystem-AUR/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-devtools-AUR/)
	metapkgs+=(./arch-packages/ovsiankina-meta-package/ov-AUR/ov-desktop-apps-AUR/)

	for i in "${metapkgs[@]}"; do
		metainstallflags="--needed"
		$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
		v install-local-pkgbuild "$i" "$metainstallflags"
	done
}

install_illogical_impulse_meta_packages() {
	metapkgs=(./arch-packages/illogical-impulse/ii-{audio,backlight,basic,fonts-themes,kde,portal,python,screencapture,toolkit,widgets,hyprland,microtex-git})

	for i in "${metapkgs[@]}"; do
		metainstallflags="--needed"
		$ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
		v install-local-pkgbuild "$i" "$metainstallflags"
	done
}

install_illogical_impulse_python_packages() {
	showfun install-python-packages
	v install-python-packages
}

install_depedencies() {
	v remove_bashcomments_emptylines ${DEPLISTFILE} ./cache/dependencies_stripped.conf
	readarray -t pkglist <./cache/dependencies_stripped.conf

	install_yay

	if ((${#pkglist[@]} != 0)); then
		if $ask; then
			for i in "${pkglist[@]}"; do v yay -S --needed $i; done
		else
			v yay -S --needed --noconfirm ${pkglist[*]}
		fi
	fi

	showfun handle-deprecated-dependencies
	v handle-deprecated-dependencies

	install_ovsiankina_meta_packages
	install_ovsiankina_AUR_meta_packages
	install_illogical_impulse_meta_packages
	v install_tmux_plugins
	v install_qwerty_fr
	install_illogical_impulse_python_packages
}

setup_user_grp() {
	v sudo usermod -aG video,i2c,input "$(whoami)"
	v bash -c "echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf"
	v systemctl --user enable ydotool --now
	v sudo systemctl enable bluetooth --now
}

sync_end4_upstream() {
	# Sync tracked files from end-4 fork into dotfiles BEFORE stow runs.
	# This ensures quickshell/ii and other tracked upstream configs
	# are up to date in ~/dotfiles/ so stow symlinks the right thing.
	local sync_script="$SCRIPT_DIR/scriptdata/end4-sync.sh"

	if [ ! -f "$sync_script" ]; then
		echo -e "\e[33m[$0]: end4-sync.sh not found, skipping upstream sync.\e[0m"
		return 0
	fi

	echo -e "\e[34m[$0]: Checking for upstream end-4 updates...\e[0m"
	v bash "$sync_script"
}

configure_kwallet_pam() {
	echo "Configuring KWallet PAM integration..."
	local pam_file="/etc/pam.d/system-login"
	local pam_line="session    optional   pam_kwallet5.so autologin"

	# Check if line already exists
	if grep -q "pam_kwallet5.so" "$pam_file" 2>/dev/null; then
		echo "KWallet PAM module already configured."
		return 0
	fi

	# Add after pam_keyinit.so line
	if grep -q "pam_keyinit.so" "$pam_file"; then
		v sudo sed -i "/pam_keyinit.so/a\\$pam_line" "$pam_file"
		echo "KWallet PAM module added to $pam_file"
	else
		echo "ERROR: Could not find pam_keyinit.so in $pam_file"
		return 1
	fi
}

symlink_with_stow() {
	echo "Creating symlinks with stow ..."
	x cd "$HOME/dotfiles"
	v stow --adopt .
	x cd "$HOME"
}

source_zsh() {
	echo "Sourcing the new shell ..."
	v chsh -s $(which zsh)
	v eval zsh
	v zsh -c "source '$HOME/dotfiles/.zshrc'"
}

clean() {
	echo "Cleaning ..."
	x cd "$HOME"
	v sudo rm -rf yay .config/yay .tmux .bash /tmp/.bash
	v chsh -s /bin/bash
	v sudo chsh -s /bin/bash

	x cd "$HOME/dotfiles"
	v stow -D .
	x cd "$HOME"

	exit 0
}

main() {
	check_distro
	prevent_sudo_or_root
	ask
	################################################################################
	printf "\e[36m[$0]: 1. Get packages and setup user groups/services\n\e[0m"
	update_sys
	install_depedencies
	setup_user_grp
	sync_end4_upstream
	configure_kwallet_pam
	################################################################################
	printf "\e[36m[$0]: 2. Copying + Configuring\e[0m\n"
	v mkdir -p $XDG_BIN_HOME $XDG_CACHE_HOME $OV_DOT $XDG_DATA_HOME
	symlink_with_stow
	source_zsh

	sleep 1
	try hyprctl reload

	printf "\e[36m[$0]: Finished\e[0m\n"
}

main
