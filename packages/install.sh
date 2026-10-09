#!/bin/bash
set -e

cd "$(dirname "$0")"

export PATH="$HOME/.nix-profile/bin:$PATH:/opt/homebrew/bin"

if [ "$#" -eq 0 ]; then
    set -- *.txt
fi

for list_file in "$@"; do
    [[ -e "$list_file" ]] || continue

    case "$list_file" in
        "Aur.txt")
            if command -v yay > /dev/null 2>&1; then
                echo "Install AUR Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | xargs -r yay -S --needed --noconfirm
            fi
            ;;
        "Pacman.txt")
            if command -v pacman > /dev/null 2>&1; then
                echo "Install Pacman Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | sudo xargs -r pacman -S --needed --noconfirm
            fi
            ;;
        "Brewfile")
            if command -v brew > /dev/null 2>&1; then
                echo "Install Homebrew Packages: $list_file"
                brew bundle --file "$list_file"
            fi
            ;;
        "Node.txt")
            if ! command -v mise > /dev/null 2>&1; then
                echo "mise is not available. Apply the Home Manager configuration first." >&2
                exit 1
            fi
            mise use --global node@lts
            echo "Install Node Packages: $list_file"
            while IFS= read -r package || [ -n "$package" ]; do
                package="${package%$'\r'}"
                [[ "$package" =~ ^[[:space:]]*(#|$) ]] && continue
                mise exec -- mise use --global "npm:$package"
            done < "$list_file"
            ;;
        *)
            echo "Skip: $list_file"
            ;;
    esac
done
