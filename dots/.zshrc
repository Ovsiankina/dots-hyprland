# ==============================================
# zinit plugins / configuration
# ==============================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# TODO: update automatically zinit periodically with `zinit 
# starship loaded with zinit might be better ?

ZINIT_MODE=light #'load' for debug (slower)

# ==============================================
# Plugins
# ==============================================
zinit ice depth=1
zinit $ZINIT_MODE zsh-users/zsh-syntax-highlighting
zinit $ZINIT_MODE zsh-users/zsh-completions
zinit $ZINIT_MODE zsh-users/zsh-autosuggestions
zinit $ZINIT_MODE Aloxaf/fzf-tab
zinit $ZINIT_MODE jeffreytse/zsh-vi-mode

# ==============================================
# Zinit Config
# ==============================================
# ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL
export ZVM_STARSHIP="INACTIVE"

# Snippets (Oh My ZSH plugins without OMZP framework)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux

autoload -Uz compinit && compinit
zinit cdreplay -q

# config
bindkey -v
bindkey '^k' history-search-backward
bindkey '^j' history-search-forward
KEYTIMEOUT=1

# ==============================================
#  ZSH options
# ==============================================

HISTFILE=~/.zsh/.zsh_history
HISTSIZE=2000
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory 
setopt sharehistory
setopt hist_ignore_space # prevent command hist when a space is put before it
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

unsetopt autocd beep

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ==============================================
# Sources
# ==============================================

source ~/.zsh/aliases.zsh
source ~/.zsh/aliases_functions.zsh
source ~/.zsh/ovsiankina_wrapper.zsh

# Keep GNU Stow behavior predictable: default target is $HOME.
# This prevents accidental links inside the dotfiles repo when running from dots/.
stow() {
  local has_target=0
  local arg
  for arg in "$@"; do
    case "$arg" in
      -t|--target|--target=*)
        has_target=1
        ;;
    esac
  done

  if (( has_target )); then
    command stow "$@"
  else
    command stow --target="$HOME" "$@"
  fi
}

# ==============================================
# Eval
# ==============================================

eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(thefuck --alias fuck)"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(zoxide init --cmd cd zsh)"


# ==============================================
# Terminal colors
# ==============================================

# run in subshell to make it quiet
# (wal -i $(cat $HOME/.local/state/current-wallpaper) -a "alpha" -q &)

# ==============================================
# Bonus (slows down startup time)
# ==============================================

# wal --preview 
# neofetch
# krabby random
# cbonsai -p

# ==============================================
# Unused
# ==============================================

export PATH="$HOME/.cargo/bin:$PATH"

# Java
#export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
#export _JAVA_AWT_WM_NONREPARENTING=1

# Display for XLaunch (WSL2)
# WARN: Only set on WSL2 ! This breaks the Vulkan drivers if set on linux
# export DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0

# opencode
export PATH=$HOME/.opencode/bin:$PATH
