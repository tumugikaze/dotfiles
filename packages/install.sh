#!/bin/bash
set -e

cd "$(dirname "$0")"

for list_file in *.txt; do
    [[ -e "$list_file" ]] || continue

    case "$list_file" in
        "Aur.txt")
            if command -v yay > /dev/null 2>&1; then
                echo "📦 Install AUR Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | xargs -r yay -S --needed --noconfirm
            fi
            ;;
        "Cargo.txt")
            if command -v cargo > /dev/null 2>&1; then
                echo "📦 Install Cargo Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | xargs -r cargo install
            fi
            ;;
        "Pacman.txt")
            if command -v pacman > /dev/null 2>&1; then
                echo "📦 Install Pacman Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | sudo xargs -r pacman -S --needed --noconfirm
            fi
            ;;
        "Node.txt") 
            if command -v node > /dev/null 2>&1; then
                echo "📦 Install Node Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | xargs -r volta install
            fi
            ;;
        "Brew.txt")
            if command -v brew > /dev/null 2>&1; then
                echo "📦 Install Homebrew Packages: $list_file"
                grep -E -v '^\s*(#|$)' "$list_file" | xargs -r brew install
            fi
            ;;
        *)
            echo "⚠️ Skip: $list_file"
            ;;
    esac
done
