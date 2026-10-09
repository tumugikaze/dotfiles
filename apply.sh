#!/bin/bash
set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DOTFILES_DIR/lib.sh"

resolve_environment "$@"

load_nix

if ! command -v nix >/dev/null 2>&1; then
    echo "Nix is not available. Run setup.sh <environment> first." >&2
    exit 1
fi

if [ ! -f "$DOTFILES_DIR/flake.lock" ]; then
    echo "flake.lock is missing. Run update.sh first." >&2
    exit 1
fi

BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

nix --extra-experimental-features "nix-command flakes" build \
    --no-update-lock-file \
    --out-link "$BUILD_DIR/result" \
    "$DOTFILES_DIR#homeConfigurations.\"$PROFILE\".activationPackage"

"$BUILD_DIR/result/activate"

save_environment
