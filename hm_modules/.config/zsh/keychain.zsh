ssh_keys=(
    deb2nix
    nix2git
    deb2git
    nix2nasu
    deb2nasu
    nix2nvr
    deb2nvr
)

KEYCHAIN_SH="$HOME/.keychain/$(hostname -s)-sh"

[[ -f "$KEYCHAIN_SH" ]] && source "$KEYCHAIN_SH"

if ! ssh-add -l &>/dev/null; then
    keychain --quiet "${ssh_keys[@]}"
    source "$KEYCHAIN_SH"
fi
