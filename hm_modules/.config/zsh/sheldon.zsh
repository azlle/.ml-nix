export SHELDON_CONFIG_FILE="$ZSH_HOME/sheldon/plugins.toml"
CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}
SHELDON_CACHE="$CACHE_DIR/sheldon_cache.zsh"

if [[ ! -r "$SHELDON_CACHE" || "$SHELDON_CONFIG_FILE" -nt "$SHELDON_CACHE" ]]; then
  mkdir -p $CACHE_DIR
  sheldon source > $SHELDON_CACHE
fi
source "$SHELDON_CACHE"

unset CACHE_DIR SHELDON_CACHE
