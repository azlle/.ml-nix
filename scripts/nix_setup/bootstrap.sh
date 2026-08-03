#!/usr/bin/env bash
set -e

echo "- Nix Installation (Step 1/2)"
sudo -v

echo "Installing Nix..."
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

echo "Configuring nix.conf..."
sudo tee -a /etc/nix/nix.conf > /dev/null <<EOF

experimental-features = nix-command flakes
trusted-users = root $USER
EOF

echo "Cloning dotfiles repository..."
git clone https://codeberg.org/Azlle/.ml-nix.git "$HOME/.ml-nix"

echo "Registering install.sh to run on next login..."
tee -a "$HOME/.bashrc" > /dev/null << EOF
bash "$HOME/.ml-nix/scripts/nix_setup/install.sh"
EOF

echo ""
echo "- Step 1 Complete! Rebooting in 3 seconds..."
sleep 3

if uname -r | grep -qi WSL2; then
    wsl.exe --shutdown
else
    sudo reboot
fi
