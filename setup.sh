#!/bin/bash
set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/lib.sh"

resolve_environment "$@"

load_nix

if ! command -v nix >/dev/null 2>&1; then
    echo "Installing Nix..."
    curl -fsSL https://nixos.org/nix/install | sh
fi

if [ "$PROFILE" = darwin ] && [ ! -x /opt/homebrew/bin/brew ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

bash "$DOTFILES_DIR/apply.sh" "$PROFILE"

# Writable per-machine files that Home Manager does not manage
for local_file in "$HOME/.zshrc.local" "$HOME/.gitconfig"; do
    if [ ! -e "$local_file" ] && [ ! -L "$local_file" ]; then
        echo "Creating $local_file..."
        (umask 077 && : > "$local_file")
    fi
done
