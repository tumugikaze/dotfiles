{ pkgs, lib, username, config, ... }:

{
  home = {
    inherit username;
    stateVersion = "24.11";
    backupFileExtension = "bak";

    packages = with pkgs; [
      jq
      zip
      unzip
      curl
      lsd
      ripgrep
      bat
      wget
      tree
      htop
      terraform

      go
      zig
      rustup
      uv
      zsh-completions

      # Language servers (rust-analyzer comes from rustup)
      lua-language-server
      typescript-language-server
      pyright
      gopls
    ];

  };

  xdg.configFile = {
    "starship.toml".source = ../.config/starship.toml;
    "nvim".source = ../.config/nvim;
    "ghostty".source = ../.config/ghostty;
  };

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "lsd";
      la = "lsd -a";
      ll = "lsd -lha";
      grep = "rg";
      cat = "bat";
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 600 ''
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '')
      ''
        if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        elif [[ -r "$HOME/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source "$HOME/.nix-profile/etc/profile.d/nix.sh"
        fi
        [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

        bindkey "^[[1;5C" forward-word    # Ctrl+Right
        bindkey "^[[1;5D" backward-word   # Ctrl+Left
        bindkey "^H" backward-kill-word   # Ctrl+Backspace
        bindkey '^[[3~' delete-char       # Delete key
        bindkey '^[[3;5~' kill-word       # Ctrl + Delete
      ''
    ];
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

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
    # Signing key and signByDefault are per machine (~/.gitconfig).
    # The default signer is Nix's ssh-keygen, which supports FIDO2 (YubiKey) keys.
    signing.format = "ssh";
    settings = {
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      core.editor = "nvim";
      sequence.editor = "nvim";
      help.autoCorrect = "prompt";
    };
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.cargo/bin"
  ];

}

