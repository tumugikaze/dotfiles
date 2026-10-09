#!/bin/bash
set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/lib.sh"

if [ "$#" -ne 0 ]; then
    echo "Usage: $0" >&2
    exit 1
fi

load_nix

if ! command -v nix >/dev/null 2>&1; then
    echo "Nix is not available. Run setup.sh <environment> first." >&2
    exit 1
fi

cd "$DOTFILES_DIR"
nix --extra-experimental-features "nix-command flakes" flake update
