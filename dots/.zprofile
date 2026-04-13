# make nvim default editor
export EDITOR=nvim
export TERM=kitty
# Keymap layout
export XKB_DEFAULT_LAYOUT=us_qwerty-fr
# set .config path
export XDG_CONFIG_HOME="$HOME/.config"
# set dotfiles path
export DOTFILES="$HOME/dotfiles/"
# Better `man` pager using bat
export MANROFFOPT='-c'
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export PYENV_ROOT="$HOME/.pyenv"

# Path modifications
export PATH="$HOME/.tmux/tmuxifier/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"

# Tool init
eval "$(pyenv init --path)"

# Added by Toolbox App
export PATH="$PATH:$HOME/.local/share/JetBrains/Toolbox/scripts"

# Launch Hyprland !  
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  start-hyprland
fi
