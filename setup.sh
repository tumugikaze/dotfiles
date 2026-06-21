#!/bin/bash
set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_USER="$(whoami)"

SUFFIX="${1:+-$1}"
PROFILE="${CURRENT_USER}${SUFFIX}"

echo "==> Start Setup... (user: $CURRENT_USER, profile: $PROFILE)"

# --- Nix ---
if ! command -v nix >/dev/null 2>&1; then
    echo "Installing Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
    # shellcheck source=/dev/null
    source "$HOME/.nix-profile/etc/profile.d/nix.sh"
else
    source "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || true
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

# --- flake.lock生成 ---
if [ ! -f "$DOTFILES_DIR/flake.lock" ]; then
    echo "Generating flake.lock..."
    nix flake update "$DOTFILES_DIR"
fi

# --- Home Manager ---
if ! command -v home-manager >/dev/null 2>&1; then
    echo "Installing Home Manager..."
    HM_REV=$(grep -A2 '"home-manager"' "$DOTFILES_DIR/flake.lock" \
        | grep '"rev"' \
        | sed 's/.*"\(.*\)".*/\1/')
    echo "Using home-manager rev: $HM_REV"
    nix profile install \
        "github:nix-community/home-manager/${HM_REV}#packages.$(nix eval --impure --expr 'builtins.currentSystem' --raw).home-manager"
fi

echo "==> Running Home Manager switch with profile: $PROFILE"
home-manager switch --flake "$DOTFILES_DIR#$PROFILE"

# --- HackGen Nerd Font ---
FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="HackGenNerdFont"
echo "Checking Nerd Fonts ($FONT_NAME)..."
if [ ! -d "$FONT_DIR" ] || ! ls "$FONT_DIR" 2>/dev/null | grep -q "$FONT_NAME"; then
    echo "Installing HackGen Nerd Font..."
    mkdir -p "$FONT_DIR"
    curl -L -o "/tmp/HackGen.zip" \
        "https://github.com/yuru7/HackGen/releases/download/v2.10.0/HackGen_v2.10.0.zip"
    unzip -o -q "/tmp/HackGen.zip" -d "$FONT_DIR"
    rm "/tmp/HackGen.zip"
    if command -v fc-cache >/dev/null 2>&1; then
        echo "Updating font cache..."
        fc-cache -fv
    fi
else
    echo "HackGen Nerd Font is already installed."
fi

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
ZSH_PATH="$(command -v zsh 2>/dev/null || echo "")"
if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$ZSH_PATH"
fi

echo "✅ All Setup Completed!"

