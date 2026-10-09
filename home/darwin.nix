{ pkgs, lib, username, ... }:

{
  imports = [ ./default.nix ];

  home.homeDirectory = "/Users/${username}";

  # Apple's OpenSSH lacks FIDO2 support, so use Nix's for YubiKey (sk) keys.
  home.packages = [ pkgs.openssh ];
  programs.git.settings.core.sshCommand = "${pkgs.openssh}/bin/ssh";

  # Homebrew is appended after Nix so Nix-managed tools take precedence.
  # fpath must be set before compinit (order 570).
  programs.zsh.initContent = lib.mkOrder 550 ''
    if [[ -x /opt/homebrew/bin/brew ]]; then
      export HOMEBREW_PREFIX=/opt/homebrew
      export HOMEBREW_CELLAR=/opt/homebrew/Cellar
      export HOMEBREW_REPOSITORY=/opt/homebrew
      path+=(/opt/homebrew/bin /opt/homebrew/sbin)
      fpath+=(/opt/homebrew/share/zsh/site-functions)
    fi
  '';
}
