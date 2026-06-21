{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = { system, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ ./home/default.nix ] ++ extraModules;
        };
    in
    {
      # base (Ubuntu / Debian / LXC / Desktop)
      homeConfigurations."linux" = mkHome {
        system = "x86_64-linux";
      };

      # base + Hyprland (Laptop専用)
      homeConfigurations."linux-hyprland" = mkHome {
        system = "x86_64-linux";
        extraModules = [ ./home/arch.nix ];
      };

      # aarch64 (VM等)
      homeConfigurations."linux-arm" = mkHome {
        system = "aarch64-linux";
      };
    };
}

