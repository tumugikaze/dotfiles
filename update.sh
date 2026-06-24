#!/bin/bash
set -e

source ~/.nix-profile/etc/profile.d/nix.sh 2>/dev/null || true

echo "==> Update Start..."

# --- Nix管理のツール ---
echo "Updating Nix flake..."
nix flake update
home-manager switch --flake .#"$(whoami)"

# --- 自己管理型ツールチェーン ---
echo "Updating rustup..."
rustup update

echo "Updating uv..."
uv self update

echo "Updating volta / node..."
volta install node@lts

echo "Updating GHCup..."
ghcup upgrade 2>/dev/null || true

echo "Updating SDKMAN..."
source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null && sdk selfupdate 2>/dev/null || true

echo "✅ Update Completed!"
