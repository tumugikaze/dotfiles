{ pkgs, username, ... }:

{
  imports = [ ./activation.nix ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      # Shell utils
      fzf
      jq
      unzip
      curl
      gdb

      # Modern CLI (旧Cargo.txt)
      lsd
      ripgrep
      bat
      zoxide
      delta

      # Languages
      go
      zig

      # Fonts
      hackgen-nerd-font
    ];

    file = {
      ".aliases".source = ../.aliases;
      ".zshrc.local" = {
        text = ''
          # This file is for local configuration (tokens, secrets).
          # It is excluded from Git.
        '';
        force = false;
      };
    };
  };

  xdg.configFile = {
    "fcitx5" = {
      source = ../.config/fcitx5;
      recursive = true;
    };
    "starship.toml".source = ../.config/starship/starship.toml;
    "sheldon".source = ../.config/sheldon;
    "nvim".source = ../.config/nvim;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      source ~/.aliases
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

      eval "$(zoxide init zsh)"

      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # delta をトップレベルで管理
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      core.editor = "nvim";
      sequence.editor = "nvim";
      help.autoCorrect = "prompt";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

