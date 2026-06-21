{ pkgs, ... }:

{
  imports = [ ./activation.nix ];

  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "24.11";

    # Cargo.txtで管理していたツール群 + その他base
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

    # dotfilesのシンボリックリンク管理
    # setup.shで手動リンクしていた部分をNixに移植
    # 実際のファイルパスは環境に合わせて調整する
    file = {
      ".aliases".source = ../.aliases;
      ".zshrc.local" = {
        text = ''
          # This file is for local configuration (tokens, secrets).
          # It is excluded from Git.
        '';
        # すでに存在する場合は上書きしない
        force = false;
      };
    };
  };

  # .config/ 配下のリンク
  xdg.configFile = {
    "fcitx5" = {
      source = ../.config/fcitx5;
      # fcitx5/profileはread-only
      recursive = true;
    };
    "starship.toml".source = ../.config/starship/starship.toml;
    "sheldon".source = ../.config/sheldon;
    "nvim".source = ../.config/nvim;
  };

  # zsh
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      source ~/.aliases
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

      # zoxide
      eval "$(zoxide init zsh)"

      # volta
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"

      # cargo
      export PATH="$HOME/.cargo/bin:$PATH"

      # uv
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # starship
  programs.starship = {
    enable = true;
    # 設定は .config/starship.toml で管理
    enableZshIntegration = true;
  };

  # git + delta
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };
    extraConfig = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      core.editor = "nvim";
      sequence.editor = "nvim";
      help.autoCorrect = "prompt";
    };
  };

  # neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # sheldon (zshプラグイン管理)
  # home.packagesに入れつつ設定はxdg.configFileで管理
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

