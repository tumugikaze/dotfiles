#!/bin/bash

set -e

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "==> Start Setup..."

if exists brew; then
    echo "Detected: Homebrew"
    INSTALL_CMD="brew install"
elif exists pacman; then
    echo "Detected: Pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
elif exists apt; then
    echo "Detected: Apt"
    INSTALL_CMD="sudo apt install -y"
    sudo apt update
elif exists dnf; then
    echo "Detected: Dnf"
    INSTALL_CMD="sudo dnf install -y"
else
    echo "Error: Supported package manager not found."
    exit 1
fi

# --- curl, unzip, jq ---
if ! exists curl; then
    echo "Installing curl..."
    $INSTALL_CMD curl
fi

if ! exists jq; then
    echo "Installing jq..."
    $INSTALL_CMD jq
fi

if ! exists unzip; then
    echo "Installing unzip..."
    $INSTALL_CMD unzip
fi

# --- Build tools ---
if ! exists cc; then
    echo "Linker 'cc' not found. Installing build tools..."
    if exists brew; then
        echo "Checking Xcode Command Line Tools..."
        if ! xcode-select -p >/dev/null 2>&1; then
            echo "Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "Please complete the Xcode installation dialog and run this script again."
            exit 1
        fi
    elif exists pacman; then
        sudo pacman -S --noconfirm base-devel
    elif exists apt; then
        $INSTALL_CMD build-essential
    elif exists dnf; then
        sudo dnf groupinstall -y "Development Tools"
    fi
fi
if ! exists gdb; then
    echo "Installing gdb..."
    $INSTALL_CMD gdb
fi

# --- fzf ---
if ! exists fzf; then
    echo "Installing fzf..."
    $INSTALL_CMD fzf
else
    echo "fzf is already installed."
fi

# --- Rust toolchain ---
if ! exists cargo; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    source "$HOME/.cargo/env"
fi

# --- uv ---
if ! exists uv; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
fi

# --- Zig ---
if ! exists zig; then
    echo "Installing Zig..."
    if exists brew || exists pacman; then
        $INSTALL_CMD zig
    else
        echo "Fetching stable Zig version info..."
        ARCH=$(uname -m)
        if [ "$ARCH" == "x86_64" ]; then
            ZIG_ARCH="x86_64-linux"
        elif [ "$ARCH" == "aarch64" ]; then
            ZIG_ARCH="aarch64-linux"
        else
            echo "Error: Unsupported architecture for Zig auto-install: $ARCH"
            exit 1
        fi

        ZIG_VER=$(curl -s https://ziglang.org/download/index.json | jq -r 'keys | map(select(. != "master")) | sort_by(split(".") | map(tonumber)) | last')
        ZIG_URL=$(curl -s https://ziglang.org/download/index.json | jq -r --arg v "$ZIG_VER" --arg a "$ZIG_ARCH" '.[$v][$a]["tarball"]')
        
        echo "Detected latest Zig version: $ZIG_VER"
        echo "Downloading from: $ZIG_URL"
        DEST_DIR="$HOME/.local"
        BIN_DIR="$HOME/.local/bin"
        
        mkdir -p "$DEST_DIR"
        mkdir -p "$BIN_DIR"
        curl -L -o "/tmp/zig.tar.xz" "$ZIG_URL"
        rm -rf "$DEST_DIR/zig-$ZIG_ARCH-$ZIG_VER"
        tar -C "$DEST_DIR" -xJf "/tmp/zig.tar.xz"
        ln -sf "$DEST_DIR/zig-$ZIG_ARCH-$ZIG_VER/zig" "$BIN_DIR/zig"
        rm "/tmp/zig.tar.xz"
        echo "Zig installed."
    fi
fi

# --- Go ---
if ! exists go; then
    echo "Installing Go..."
    if exists brew || exists pacman; then
        $INSTALL_CMD go
    else
        echo "Fetching latest Go version info..."
        
        ARCH=$(uname -m)
        if [ "$ARCH" == "x86_64" ]; then
            GO_ARCH="amd64"
        elif [ "$ARCH" == "aarch64" ]; then
            GO_ARCH="arm64"
        else
            echo "Error: Unsupported architecture for Go auto-install: $ARCH"
            exit 1
        fi
        
        GO_FILE=$(curl -s "https://go.dev/dl/?mode=json" | jq -r --arg a "$GO_ARCH" '.[0].files[] | select(.os == "linux" and .arch == $a) | .filename')
        GO_VER=$(curl -s "https://go.dev/dl/?mode=json" | jq -r '.[0].version')
        GO_URL="https://go.dev/dl/${GO_FILE}"
        
        if [ -z "$GO_FILE" ] || [ "$GO_FILE" == "null" ]; then
            echo "Error: Failed to find Go binary for linux-$GO_ARCH"
            exit 1
        fi

        echo "Detected latest Go version: $GO_VER"
        echo "Downloading from: $GO_URL"
        
        DEST_DIR="$HOME/.local/go"
        BIN_DIR="$HOME/.local/bin"
        
        mkdir -p "$DEST_DIR"
        mkdir -p "$BIN_DIR"
        
        curl -L -o "/tmp/go.tar.gz" "$GO_URL"
        
        rm -rf "$DEST_DIR"
        
        tar -C "$HOME/.local" -xzf "/tmp/go.tar.gz"
        
        ln -sf "$DEST_DIR/bin/go" "$BIN_DIR/go"
        ln -sf "$DEST_DIR/bin/gofmt" "$BIN_DIR/gofmt"
        
        rm "/tmp/go.tar.gz"
        echo "Go installed to $DEST_DIR"
    fi
fi

# --- Node ---
if ! exists volta; then
    echo "Installing Node(volta)..."
    curl https://get.volta.sh | bash
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"
    volta install node
fi

# --- Neovim ---
if ! exists nvim; then
    echo "Installing Neovim..."
    if [ "$(uname)" == "Darwin" ]; then
        brew install neovim
    else        
        NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        DEST_DIR="$HOME/.local"
        BIN_DIR="$HOME/.local/bin"
        
        mkdir -p "$DEST_DIR"
        mkdir -p "$BIN_DIR"

        curl -L -o "/tmp/nvim-linux-x86_64.tar.gz" "$NVIM_URL"
        rm -rf "$DEST_DIR/nvim-linux-x86_64"
        tar -C "$DEST_DIR" -xzf "/tmp/nvim-linux-x86_64.tar.gz"
        ln -sf "$DEST_DIR/nvim-linux-x86_64/bin/nvim" "$BIN_DIR/nvim"
        rm "/tmp/nvim-linux-x86_64.tar.gz"
    fi
fi

# --- Zsh ---
if ! exists zsh; then
    echo "Installing zsh..."
    $INSTALL_CMD zsh
fi

# --- Sheldon ---
if ! exists sheldon; then
    echo "Installing sheldon..."
    if exists brew || exists pacman; then
        $INSTALL_CMD sheldon
    else
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    fi
fi

# Ghostty
if ! exists ghostty; then
    echo "Installing Ghostty..."
    if exists brew; then
        brew install --cask ghostty
    elif exists pacman; then
        sudo pacman -S --noconfirm ghostty
    fi
fi

# --- Rust made tools ---
if ! exists lsd; then
    # lsd
    echo "Installing lsd..."
    if exists brew || exists pacman || exists dnf; then
        $INSTALL_CMD lsd
    else
        cargo install lsd
    fi
fi
if ! exists starship; then
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
if ! exists rg; then
    echo "Installing ripgrep..."
    if exists brew || exists pacman || exists dnf || exists apt; then
        $INSTALL_CMD ripgrep
    else 
        cargo install ripgrep
    fi
fi
if ! exists bat; then
    echo "Installing bat..."
    if exists brew || exists pacman || exists dnf; then
        $INSTALL_CMD bat
    elif exists apt; then
        $INSTALL_CMD bat
        mkdir -p "$HOME/.local/bin"
        if exists batcat; then
            ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
        fi
    else 
        cargo install --locked bat
    fi
fi
if ! exists zoxide; then
    echo "Installing zoxide..."
    if exists brew || exists pacman; then
        $INSTALL_CMD zoxide
    else
        cargo install zoxide
    fi
fi
if ! exists delta; then
    echo "Installing delta..."
    if exists brew || exists pacman; then
        $INSTALL_CMD git-delta
    else
        cargo install git-delta
    fi
fi

# --- Nerd Fonts ---
FONT_NAME="JetBrainsMono"
echo "Checking Nerd Fonts ($FONT_NAME)..."

if [ "$(uname)" == "Darwin" ]; then
    if ! brew list --cask | grep -q "font-jetbrains-mono-nerd-font"; then
        echo "Installing Nerd Font via Homebrew..."
        brew install --cask font-jetbrains-mono-nerd-font
    else
        echo "Nerd Font is already installed."
    fi
elif exists pacman; then
    $INSTALL_CMD ttf-jetbrains-mono-nerd
else
    FONT_DIR="$HOME/.local/share/fonts"
    if [ ! -d "$FONT_DIR" ]; then
        mkdir -p "$FONT_DIR"
    fi

    if ! ls "$FONT_DIR" | grep -q "$FONT_NAME"; then
        echo "Installing Nerd Font manually..."
        VERSION="v3.4.0"
        ZIP_FILE="${FONT_NAME}.zip"
        URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}/${ZIP_FILE}"
        
        curl -L -o "/tmp/$ZIP_FILE" "$URL"
        unzip -o -q "/tmp/$ZIP_FILE" -d "$FONT_DIR"
        rm "/tmp/$ZIP_FILE"
        
        if exists fc-cache; then
            echo "Updating font cache..."
            fc-cache -fv
        fi
    else
        echo "Nerd Font is already installed in $FONT_DIR."
    fi
fi

# --- Local Settings ---
echo "==> Configuring Environment..."
if [ ! -f "$HOME/.zshrc.local" ]; then
    echo "Creating .zshrc.local (for secret envs)..."
    touch "$HOME/.zshrc.local"
    echo "# This file is for local configuration (tokens, secrets)." >> "$HOME/.zshrc.local"
    echo "# It is excluded from Git." >> "$HOME/.zshrc.local"
fi

# --- Link Configs ---
echo "==> Linking Configs..."
mkdir -p "$HOME/.config"

# Link files
[ -f "$DOTFILES_DIR/.zshrc" ] && ln -snf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.aliases" ] && ln -snf "$DOTFILES_DIR/.aliases" "$HOME/.aliases"

# Link .config
if [ -d "$DOTFILES_DIR/.config" ]; then
    for config_dir in "$DOTFILES_DIR/.config"/*; do
        if [ -d "$config_dir" ] || [ -f "$config_dir" ]; then
            target="$HOME/.config/$(basename "$config_dir")"
            ln -snf "$config_dir" "$target"
            echo "Linked $(basename "$config_dir") to $target"
        fi
    done
fi
echo "Links created."

# --- Git Configuration ---
echo "==> Git Configuration..."
if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter Git user.name: " git_name
    git config --global user.name "$git_name"
fi

if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter Git user.email: " git_email
    git config --global user.email "$git_email"
fi

if exists delta; then
    echo "Setting up Git Delta..."
    git config --global core.pager delta
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.side-by-side true
    git config --global merge.conflictstyle diff3
    git config --global diff.colorMoved default
    git config --global core.editor "vim"
    git config --global sequence.editor "vim"
    git config --global help.autoCorrect prompt
fi

# --- Default shell change ---
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
fi

echo "✅ All Setup Completed!"
