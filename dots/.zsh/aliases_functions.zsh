function ls() {
    local args="$@"
    if [[ "$args" == *"-l"* ]]; then
        eza --long --icons=always "$@"
    elif [[ "$args" == *"-g"* ]]; then
        eza --color=always --long --git -a --git-ignore --no-filesize --icons=always --no-time --no-user --no-permissions "$@"
    else
        eza --color=always -x --git --no-filesize --icons=always --no-time --no-user --no-permissions "$@"
    fi
}

function tree(){
    eza -T
}

# zinit vim mode will auto execute this function automatically when needed
function zvm_after_select_vi_mode() {
	# NOTE: ${foo:u} expansion converts string to uppercase
	# source: https://zsh.sourceforge.io/Doc/Release/Expansion.html
	export ZVM_STARSHIP=${ZVM_MODE:u} # 
  # case $ZVM_MODE in
  #   n)  export ZVM="N" ;;
  #   i)  export ZVM="I" ;;
  #   v)  export ZVM="V" ;;
  #   vl) export ZVM="VL" ;;
  #   c)  export ZVM="C" ;;
  #   r)  export ZVM="R" ;;
  #   *)  export ZVM=" " ;;
  # esac
}
