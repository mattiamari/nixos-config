{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-2411.url = "nixpkgs/nixos-24.11";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    meross-prometheus-exporter.url = "github:mattiamari/meross-prometheus-exporter";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-2411,
      home-manager,
      catppuccin,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgsStable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs2411 = import nixpkgs-2411 {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./overlays { inherit pkgsStable pkgs2411; }) ];
      };

      lib = nixpkgs.lib;

      mkHost =
        {
          hostName,
          hmUsers ? [ ],
          extraModules ? [ ],
        }:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules =
            [
              { nixpkgs.pkgs = pkgs; }
              ./hosts/${hostName}
            ]
            ++ lib.optionals (hmUsers != [ ]) [
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit catppuccin; };
                home-manager.users = lib.genAttrs hmUsers (name: import ./home/${name});
              }
            ]
            ++ extraModules;
        };

      mkHMConfig = name: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home/${name} ];
        extraSpecialArgs = { inherit catppuccin; };
      };
    in
    {
      nixosConfigurations = {

        bart = mkHost {
          hostName = "bart";
          hmUsers = [ "mattia" "work" ];
          extraModules = [ catppuccin.nixosModules.catppuccin ];
        };

        homer = mkHost { hostName = "homer"; };

        marge = mkHost { hostName = "marge"; };

        wsl = mkHost {
          hostName = "wsl";
          hmUsers = [ "work" ];
          extraModules = [
            inputs.nixos-wsl.nixosModules.default
            catppuccin.nixosModules.catppuccin
          ];
        };

        rescusb = lib.nixosSystem {
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./hosts/rescusb
          ];
        };

      };

      homeConfigurations = lib.genAttrs [ "mattia" "work" ] mkHMConfig;
    };
}
