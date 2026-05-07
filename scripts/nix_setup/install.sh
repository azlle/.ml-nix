#!/usr/bin/env bash
set -e

echo "- Home Manager Setup (Step 2/2)"
sudo -v

echo ""
echo "Select your hostname:"
echo "|-------+------+------------------|"
echo "| entry | user |     hostname     |"
echo "|-------+------+------------------|"
echo "|   1   | miyu | sumizomenosakura |"
echo "|-------+------+------------------|"
echo ""

while true; do
  while true; do
    read -p "Enter number: " choice
    case $choice in
      1) hostname="sumizomenosakura"; break ;;
      *) echo "Invalid choice. Please enter a valid number." ;;
    esac
  done

  echo ""
  echo "Selected: ${hostname}"
  read -p "Are you sure? (y/n): " confirm
  case $confirm in
    [yY]) break ;;
    [nN]) echo ""; echo "Please select again." ;;
    *) echo "Please enter y or n." ;;
  esac
done

echo "Applying Home Manager configuration..."
nix run home-manager/master -- switch --flake "$HOME/.nix_ml#${hostname}" \
  --option substituters "\
    https://cache.nixos.org \
    https://nix-community.cachix.org" \
  --option trusted-public-keys "\
    cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= \
    nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

echo "Cleaning up apt packages..."
sudo apt purge -y curl xz-utils git && sudo apt autoremove -y

echo "Setting Zsh as default shell..."
sudo usermod -s "$(which zsh)" "$USER"

echo "Removing auto-run entry from .bashrc..."
sed -i '/\.nix_ml\/scripts\/nix_setup\/install\.sh/d' "$HOME/.bashrc"

echo ""
echo "- Setup Complete! Rebooting in 3 seconds..."
sleep 3

if uname -r | grep -qi WSL2; then
    wsl.exe --shutdown
else
    sudo reboot
fi
