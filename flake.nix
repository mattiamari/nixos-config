{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.05";
    nixpkgs-2411.url = "nixpkgs/nixos-24.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    nixpkgs-maven.url = "nixpkgs/79cb2cb9869d7bb8a1fac800977d3864212fd97d";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    meross-prometheus-exporter.url = "github:mattiamari/meross-prometheus-exporter";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      nixpkgs-2411,
      nixos-wsl,
      nixpkgs-maven,
      home-manager,
      catppuccin,
      meross-prometheus-exporter,
      ...
    }:
    let
      localSystem = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit localSystem;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "gradle-7.6.6"
          ];
        };
        overlays = [ (import ./overlays { inherit pkgsStable pkgs2411; }) ];
      };

      pkgsStable = import nixpkgs-stable {
        inherit localSystem;
        config.allowUnfree = true;
      };

      pkgs2411 = import nixpkgs-2411 {
        inherit localSystem;
        config.allowUnfree = true;
      };

      pkgsMaven = import nixpkgs-maven {
        inherit localSystem;
      };

      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {

        bart = lib.nixosSystem {
          modules = [
            { nixpkgs.pkgs = pkgs; }
            catppuccin.nixosModules.catppuccin
            ./hosts/bart
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mattia = import ./home-manager/mattia;
              home-manager.users.work = import ./home-manager/work;
              home-manager.extraSpecialArgs = {
                inherit catppuccin pkgsMaven;
              };
            }
          ];
        };

        homer = lib.nixosSystem {
          specialArgs = {
            meross-prometheus-exporter = meross-prometheus-exporter.packages.x86_64-linux.default;
          };
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./hosts/homer
          ];
        };

        marge = lib.nixosSystem {
          modules = [
            { nixpkgs.pkgs = pkgs; }
            ./hosts/marge
          ];
        };

        wsl = lib.nixosSystem {
          modules = [
            nixos-wsl.nixosModules.default
            catppuccin.nixosModules.catppuccin
            ./hosts/wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.work = import ./home-manager/work;
              home-manager.extraSpecialArgs = {
                inherit catppuccin pkgsMaven;
              };
            }
          ];
        };

        rescusb = lib.nixosSystem {
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./hosts/rescusb
          ];
        };

      };

      homeConfigurations = {
        mattia = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home-manager/mattia
          ];
          extraSpecialArgs = { inherit catppuccin; };
        };

        work = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home-manager/work
          ];
          extraSpecialArgs = { inherit catppuccin; };
        };
      };
    };
}
