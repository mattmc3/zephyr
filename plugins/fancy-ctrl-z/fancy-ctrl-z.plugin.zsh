# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
function fancy-ctrl-z {
  if [[ -z "$BUFFER" ]]; then
    BUFFER="fg"
    zle accept-line -w
  else
    zle push-input -w
    zle clear-screen -w
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z
