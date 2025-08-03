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

    outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-2411, nixos-wsl, nixpkgs-maven, home-manager, catppuccin, meross-prometheus-exporter, ...} @ inputs:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ (import ./overlays { inherit pkgsStable nixpkgs-2411; }) ];
        };

        pkgsStable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsMaven = import nixpkgs-maven {
          inherit system;
        };


        lib = nixpkgs.lib;
        specialArgs = { inherit meross-prometheus-exporter; };

        defaultModules = [
          ./hosts/common
        ];
      in {
        nixosConfigurations = {

          bart = lib.nixosSystem {
            inherit system specialArgs;
            modules = defaultModules ++ [
              {nixpkgs.pkgs = pkgs;}
              catppuccin.nixosModules.catppuccin
              ./hosts/bart
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.mattia = import ./home-manager/mattia;
                home-manager.users.work = import ./home-manager/work;
                home-manager.extraSpecialArgs = specialArgs // { inherit catppuccin pkgsMaven; };
              }
            ];
          };

          homer = lib.nixosSystem {
            inherit system;
            specialArgs = specialArgs // {meross-prometheus-exporter = meross-prometheus-exporter.packages.${system}.default;};
            modules = defaultModules ++ [
              {nixpkgs.pkgs = pkgs;}
              ./hosts/homer
            ];
          };

          marge = lib.nixosSystem {
            inherit system specialArgs;
            modules = defaultModules ++ [
              {nixpkgs.pkgs = pkgs;}
              ./hosts/marge
            ];
          };

          wsl = lib.nixosSystem {
            inherit system specialArgs;
            modules = defaultModules ++ [
              nixos-wsl.nixosModules.default
              catppuccin.nixosModules.catppuccin
              ./hosts/wsl
              home-manager.nixosModules.home-manager {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.work = import ./home-manager/work;
                home-manager.extraSpecialArgs = specialArgs // { inherit catppuccin pkgsMaven; };
              }
            ];
          };

          rescusb = lib.nixosSystem {
            inherit system;
            modules = [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
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
