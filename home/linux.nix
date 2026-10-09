{ pkgs, username, ... }:

{
  imports = [ ./default.nix ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };

  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    gdb
  ];
}
