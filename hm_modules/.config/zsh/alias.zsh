# evade glob
local noglob_cmds=(
  nix home-manager
  git curl wget rsync
  yt-dlp gallery-dl
)
for cmd in $noglob_cmds; do
  alias $cmd="noglob $cmd"
done

# eza.nixのextraOptionsによってaliasが定義される
# alias -- eza='eza --group-directories-first '\''--color=always'\'' --icons --git'

alias -- rmt='rm -rf ~/.local/share/Trash/files/*'
