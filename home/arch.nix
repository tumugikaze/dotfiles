{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Hyprland ecosystem
    hyprlock
    hypridle

    # Wayland utils
    grim
    slurp
    wl-clipboard
    cliphist
    mako
    brightnessctl
    playerctl

    # Audio
    pipewire
    wireplumber
    pavucontrol

    # Network / polkit
    networkmanagerapplet
    polkit_gnome

    # Portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk

    # IME
    fcitx5
    fcitx5-mozc
    fcitx5-gtk
    fcitx5-qt
    fcitx5-configtool

    # Browser
    firefox

    # Terminal
    ghostty

    # 1Password (旧Aur.txt)
    _1password-gui
    _1password-cli
  ];

  # Arch専用の.config リンク
  xdg.configFile = {
    "hypr".source = ../.config/hypr;
    "mako".source = ../.config/mako;
    "ghostty".source = ../.config/ghostty;
  };
}

