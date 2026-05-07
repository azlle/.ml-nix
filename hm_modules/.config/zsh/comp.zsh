autoload -Uz compinit

if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
  echo "Running compinit"
  compinit
  touch ~/.zcompdump
else
  echo "Running compinit -C"
  compinit -C
fi

zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

zstyle ':completion:*:descriptions' format $'\e[33m[ %d ]\e[m'
zstyle ':completion:*:warnings'     format $'\e[31m[ no matches ]\e[m'

zstyle ':completion:*' menu select
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*' matcher-list "" 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':fzf-tab:complete:cd:*' fzf-preview "eza -1 --color=always $realpath"
zstyle ':fzf-tab:*' switch-group "<" ">"
