bindkey -e

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# bindkey -vを想定したバインドなので無効化
# export KEYTIMEOUT=15
# bindkey -M viins 'jk' vi-cmd-mode
