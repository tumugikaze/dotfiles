#!/bin/bash
set -e

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

# --- Cargo製ツール (Nix管理に移行済みだが念のため) ---
# cargo install-update -a  # cargo-updateが入っている場合

echo "✅ Update Completed!"
