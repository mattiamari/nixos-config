{
    inputs = {
      nixpkgs.url = "nixpkgs/nixos-24.05";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      catppuccin.url = "github:catppuccin/nix";
      meross-prometheus-exporter.url = "github:mattiamari/meross-prometheus-exporter";
    };

    outputs = { self, nixpkgs, nixpkgsUnstable, home-manager, catppuccin, meross-prometheus-exporter, ...} @ inputs:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsUnstable = import nixpkgsUnstable {
          inherit system;
          config.allowUnfree = true;
          #overlays = import ./overlays;

          overlays = [
            (final: prev: {
              jetbrains = (prev.recurseIntoAttrs (prev.callPackages ./packages/jetbrains {
                jdk = final.jetbrains.jdk;
              }) // {
                jdk = prev.callPackage ./packages/jetbrains-jdk {
                  jdk = prev.jdk21;
                };
                jcef = prev.callPackage ./packages/jetbrains-jdk/jcef.nix {
                  jdk = prev.jdk21;
                };
              });
            })
          ];
        };
      in
      {
        nixosConfigurations =
          let
            lib = nixpkgs.lib;
            specialArgs = { inherit pkgs pkgsUnstable meross-prometheus-exporter; };

            defaultModules = [
              ./hosts/common
            ];
          in
          {

            bart = lib.nixosSystem {
              inherit system specialArgs;
              modules = defaultModules ++ [
                catppuccin.nixosModules.catppuccin
                ./hosts/bart
                home-manager.nixosModules.home-manager {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.mattia = import ./home-manager/mattia;
                  home-manager.users.work = import ./home-manager/work;
                  home-manager.extraSpecialArgs = specialArgs // { inherit catppuccin; };
                }
              ];
            };

            homer = lib.nixosSystem {
              inherit system;
              specialArgs = specialArgs // {meross-prometheus-exporter = meross-prometheus-exporter.packages.${system}.default;};
              modules = defaultModules ++ [ ./hosts/homer ];
            };

            marge = lib.nixosSystem {
              inherit system specialArgs;
              modules = defaultModules ++ [ ./hosts/marge ];
            };

            wsl = lib.nixosSystem {
              inherit system specialArgs;
              modules = defaultModules ++ [
                catppuccin.nixosModules.catppuccin
                ./hosts/wsl
                home-manager.nixosModules.home-manager {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.work = import ./home-manager/work;
                  home-manager.extraSpecialArgs = specialArgs // { inherit catppuccin; };
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
            extraSpecialArgs = { inherit pkgsUnstable catppuccin; };
          };

          work = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home-manager/work
            ];
            extraSpecialArgs = { inherit pkgsUnstable catppuccin; };
          };
        };
    };
}
