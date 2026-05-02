{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
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

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ (import ./overlays { inherit pkgsStable; }) ];
      };

      lib = nixpkgs.lib;

      mkHost =
        {
          hostName,
          hmUsers ? [ ],
          extraModules ? [ ],
          hmArgs ? { },
        }:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./hosts/${hostName}
          ]
          ++ lib.optionals (hmUsers != [ ]) [
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit catppuccin;
              }
              // hmArgs;
              home-manager.users = lib.genAttrs hmUsers (name: import ./home/${name});
            }
          ]
          ++ extraModules;
        };

      mkHMConfig =
        name:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/${name} ];
          extraSpecialArgs = { inherit catppuccin; };
        };
    in
    {
      nixosConfigurations = {

        bart = mkHost {
          hostName = "bart";
          hmUsers = [
            "mattia"
            "work"
          ];
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
          hmArgs = {
            hasDesktopEnvironment = false;
          };
        };

        rescusb = lib.nixosSystem {
          inherit system;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
            ./hosts/rescusb
          ];
        };

      };

      homeConfigurations = lib.genAttrs [ "mattia" "work" ] mkHMConfig;
    };
}
