{ lib, ... }:

{
  home.activation = {

    installRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.nix-profile/bin:$HOME/.cargo/bin:$PATH"
      if ! command -v cargo >/dev/null 2>&1; then
        $DRY_RUN_CMD echo "Installing rustup..."
        $DRY_RUN_CMD curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
          | sh -s -- -y --no-modify-path
      fi
    '';

    installVolta = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.nix-profile/bin:$HOME/.volta/bin:$PATH"
      if ! command -v volta >/dev/null 2>&1; then
        $DRY_RUN_CMD echo "Installing volta..."
        $DRY_RUN_CMD curl https://get.volta.sh | bash -s -- --skip-setup
        export VOLTA_HOME="$HOME/.volta"
        export PATH="$VOLTA_HOME/bin:$PATH"
        $DRY_RUN_CMD volta install node
      fi
    '';

    installUv = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH"
      if ! command -v uv >/dev/null 2>&1; then
        $DRY_RUN_CMD echo "Installing uv..."
        $DRY_RUN_CMD curl -LsSf https://astral.sh/uv/install.sh \
          | sh -s -- --no-modify-path
      fi
    '';

    installNodePackages = lib.hm.dag.entryAfter [ "installVolta" ] ''
      export PATH="/usr/local/bin:/usr/bin:/bin:$HOME/.nix-profile/bin:$HOME/.volta/bin:$PATH"
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
      if command -v volta >/dev/null 2>&1; then
        $DRY_RUN_CMD echo "Installing Node packages..."
        DOTFILES_DIR="${builtins.toString ../.}"
        if [ -f "$DOTFILES_DIR/packages/Node.txt" ]; then
          grep -E -v '^\s*(#|$)' "$DOTFILES_DIR/packages/Node.txt" \
            | xargs -r volta install
        fi
      fi
    '';
  };
}

