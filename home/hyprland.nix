{ pkgs, ... }:

{
  imports = [ ./linux.nix ];

  home.packages = with pkgs; [
    waybar
    wofi
    kdePackages.dolphin

    grim
    slurp
    wl-clipboard
    cliphist
    mako
    playerctl

    pavucontrol

    networkmanagerapplet

    spotify

    firefox
    chromium
  ];

  programs.zsh.shellAliases = {
    hyprland = "start-hyprland";
    spotify = "spotify &disown";
  };

  xdg.configFile = {
    "hypr".source = ../.config/hypr;
    "waybar".source = ../.config/waybar;
    "mako".source = ../.config/mako;
    "fcitx5" = {
      source = ../.config/fcitx5;
      recursive = true;
    };
  };
}

