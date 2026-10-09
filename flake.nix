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
      username = "tgz";

      mkHome = { system, module }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit username; };
          modules = [ module ];
        };

    in
    {
      homeConfigurations = {
        darwin = mkHome {
          system = "aarch64-darwin";
          module = ./home/darwin.nix;
        };
        linux = mkHome {
          system = "x86_64-linux";
          module = ./home/linux.nix;
        };
        hyprland = mkHome {
          system = "x86_64-linux";
          module = ./home/hyprland.nix;
        };
        wsl = mkHome {
          system = "x86_64-linux";
          module = ./home/wsl.nix;
        };
      };
    };
}

