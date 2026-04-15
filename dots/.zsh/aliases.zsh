#          ╭──────────────────────────────────────────────────────────╮
#          │                         Aliases                          │
#          ╰──────────────────────────────────────────────────────────╯
# alias ls='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
# alias grep='grep --color=auto'
alias grep='rg'
alias sp='sudo pacman'
alias cat='bat'
alias clip='wl-copy'
alias neofetch='fastfetch' # RIP neofetch   ( Apr 26, 2024 )

# ── fzf ───────────────────────────────────────────────────────────────
alias fzf="fzf --preview='cat {}'"
alias nvimf='nvim $(fzf)'

# ── zoxide ────────────────────────────────────────────────────────────
alias cdf='cdi'
alias cde='zoxide edit'

# ── network manager ───────────────────────────────────────────────────
alias dwr='nmcli d w r'
alias dwc='nmcli d w c --ask'
alias dwl='nmcli d w l'

# ── Zellij ────────────────────────────────────────────────────────────
alias tmux='zellij'
