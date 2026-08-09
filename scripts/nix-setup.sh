#!/usr/bin/env bash
set -e

echo "- Nix Setup"
sudo -v

ageKeyFile="/var/lib/sops-nix/sops_mm"
echo "Checking for age key at ${ageKeyFile}..."
if [ ! -f "$ageKeyFile" ]; then
  echo "Error: age key not found at ${ageKeyFile}." >&2
  echo "Copy it there (e.g. from Bitwarden) before running this script." >&2
  exit 1
fi
if [ ! -r "$ageKeyFile" ]; then
  echo "Error: age key at ${ageKeyFile} exists but isn't readable by ${USER}." >&2
  echo "Fix its ownership/permissions before running this script." >&2
  exit 1
fi

echo "Checking for a *2git SSH key under ${HOME}/.ssh..."
shopt -s nullglob
nix2gitKeys=("$HOME"/.ssh/*2git)
shopt -u nullglob
if [ ${#nix2gitKeys[@]} -eq 0 ]; then
  echo "Error: no SSH key matching *2git found under ${HOME}/.ssh." >&2
  echo "Copy it there (e.g. from Bitwarden) before running this script." >&2
  exit 1
fi
echo "Starting ssh-agent and adding *2git key(s)..."
eval "$(ssh-agent -s)"
trap 'ssh-agent -k > /dev/null' EXIT
for nix2gitKey in "${nix2gitKeys[@]}"; do
  chmod 600 "$nix2gitKey"
  ssh-add "$nix2gitKey"
done

echo "Installing Nix..."
curl --proto '=https' --tlsv1.2 -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install \
  --no-confirm \
  --enable-flakes \
  --extra-conf "trusted-users = root $USER" \
  --extra-conf "auto-optimise-store = true" \
  --extra-conf "sandbox-fallback = false"

echo "Loading Nix into this shell..."
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "Cloning dotfiles repository..."
git clone https://github.com/Azlle/.ml-nix.git "$HOME/.ml-nix"

hostname="sumizomenosakura"

echo "Applying Home Manager configuration for ${hostname}..."
nix shell nixpkgs#nh -c nh home switch "$HOME/.ml-nix" \
  -c "eeshta@${hostname}" \
  --option extra-substituters "https://nix-community.cachix.org https://attic.xuyh0120.win/lantian https://wezterm.cachix.org" \
  --option extra-trusted-public-keys "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc= wezterm.cachix.org-1:kAbhjYUC9qvblTE+s7S+kl5XM1zVa4skO+E/1IDWdH0="

echo "Cleaning up apt packages..."
sudo apt purge -y curl xz-utils git && sudo apt autoremove -y

echo "Setting Zsh as default shell..."
sudo usermod -s "$(which zsh)" "$USER"

echo ""
echo "- Setup Complete!"
echo "Log out and back in for the Zsh shell change to take effect."
