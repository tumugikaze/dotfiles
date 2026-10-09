PROFILE_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/profile"

usage() {
    echo "Usage: $0 [darwin|linux|hyprland|wsl]" >&2
}

detect_environment() {
    case "$(uname -s)" in
        Darwin) echo darwin ;;
        Linux)
            if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
                echo wsl
            elif command -v Hyprland >/dev/null 2>&1; then
                echo hyprland
            else
                echo linux
            fi
            ;;
        *) return 1 ;;
    esac
}

# Sets PROFILE from the argument, the last applied environment, or OS detection.
resolve_environment() {
    if [ "$#" -gt 1 ]; then
        usage
        return 1
    fi

    if [ "$#" -eq 1 ]; then
        PROFILE="$1"
    elif [ -r "$PROFILE_STATE" ]; then
        PROFILE="$(cat "$PROFILE_STATE")"
    elif ! PROFILE="$(detect_environment)"; then
        echo "Could not detect environment." >&2
        usage
        return 1
    fi

    case "$PROFILE" in
        darwin|linux|hyprland|wsl) ;;
        *)
            echo "Unknown environment: $PROFILE" >&2
            usage
            return 1
            ;;
    esac

    echo "Environment: $PROFILE"
}

save_environment() {
    mkdir -p "$(dirname "$PROFILE_STATE")"
    printf '%s\n' "$PROFILE" > "$PROFILE_STATE"
}

load_nix() {
    if ! command -v nix >/dev/null 2>&1; then
        for nix_profile in /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh "$HOME/.nix-profile/etc/profile.d/nix.sh"; do
            if [ -r "$nix_profile" ]; then
                source "$nix_profile"
                break
            fi
        done
    fi
}
