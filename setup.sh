#!/bin/bash
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_USER="$(whoami)"

# 引数でプロファイルsuffixを指定
# 例: ./setup.sh hyprland → tgz-hyprland
#     ./setup.sh          → tgz
SUFFIX="${1:+-$1}"
PROFILE="${CURRENT_USER}${SUFFIX}"

echo "==> Start Setup... (user: $CURRENT_USER, profile: $PROFILE)"

# --- Nix ---
if ! command -v nix >/dev/null 2>&1; then
    echo "Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    # shellcheck source=/dev/null
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# --- Nix config (experimental features) ---
NIX_CONF="$HOME/.config/nix/nix.conf"
mkdir -p "$(dirname "$NIX_CONF")"

add_nix_config() {
    local key="$1" value="$2"
    if ! grep -q "^${key}" "$NIX_CONF" 2>/dev/null; then
        echo "${key} = ${value}" >> "$NIX_CONF"
        echo "Added to nix.conf: ${key} = ${value}"
    fi
}

add_nix_config "experimental-features" "nix-command flakes"

# --- Home Manager ---
if ! command -v home-manager >/dev/null 2>&1; then
    echo "Installing Home Manager..."
    nix run home-manager/master -- init
fi

echo "==> Running Home Manager switch with profile: $PROFILE"
nix run home-manager/master -- switch --flake "$DOTFILES_DIR#$PROFILE"

# --- Git Configuration ---
echo "==> Git Configuration..."
if [ -z "$(git config --global user.name)" ]; then
    read -rp "Enter Git user.name: " git_name
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    read -rp "Enter Git user.email: " git_email
    git config --global user.email "$git_email"
fi

# --- Default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo "✅ All Setup Completed!"
