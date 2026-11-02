ssh_keys=(
    asia2git
    deb2nix
    nix2git
    deb2git
    nix2nasu
    deb2nasu
    nix2nvr
    deb2nvr
)

# keychain only adopts a PID-less agent with --ssh-allow-forwarded;
# pin the local socket so keys never go into a forwarded agent.
if [[ -S "$XDG_RUNTIME_DIR/ssh-agent" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
    unset SSH_AGENT_PID
    keychain --quiet add --ssh-allow-forwarded "${ssh_keys[@]}"
else
    KEYCHAIN_SH="$HOME/.keychain/$(hostname -s)-sh"

    [[ -f "$KEYCHAIN_SH" ]] && source "$KEYCHAIN_SH"

    if ! ssh-add -l &>/dev/null; then
        keychain --quiet "${ssh_keys[@]}"
        source "$KEYCHAIN_SH"
    fi
fi
