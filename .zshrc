export PATH="$HOME/.local/bin:$PATH"
autoload -Uz compinit && compinit

# Rust (Cargo)
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:$HOME/.local/go/bin:$GOPATH/bin"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Neovim
export NVIM_APPNAME="nvim"


# starship
eval "$(starship init zsh)"

# sheldon
eval "$(sheldon source)"

# uv
eval "$(uv generate-shell-completion zsh)"

# Aliases
if [ -f "$HOME/.aliases" ]; then
    source "$HOME/.aliases"
fi

# zoxide
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Keybindings
bindkey '^[[1;5C' forward-word # Ctrl + ->
bindkey '^[[1;5D' backward-word # Ctrl + <-
bindkey '^[[3~' delete-char # Delete key
bindkey '^H' backward-delete-word # Ctrl + Backspace
bindkey '^[[3;5~' kill-word # Ctrl + Delete


# Local configurations
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
if [ -e /home/tgz/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tgz/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
