{
  description = "tumugikaze dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, lib, ... }:
    let
      mkHome = { system, username, hyprland ? false }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username; };
          modules = [ ./home/default.nix ]
            ++ lib.optional hyprland ./home/arch.nix;
        };

      users = [
        { username = "tgz";      system = "x86_64-linux"; }
        { username = "archuser"; system = "x86_64-linux"; }
        { username = "ubuntu";   system = "x86_64-linux"; }
      ];

      # ユーザーリストからbase/hyprlandの両エントリを生成
      mkConfigs = us: builtins.listToAttrs (
        builtins.concatMap (u: [
          { name = u.username;              value = mkHome { inherit (u) system username; }; }
          { name = "${u.username}-hyprland"; value = mkHome { inherit (u) system username; hyprland = true; }; }
        ]) us
      );
    in
    {
      homeConfigurations = mkConfigs users;
    };
}

