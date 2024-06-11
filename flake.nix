{
    inputs = {
      nixpkgs.url = "nixpkgs/nixos-24.05";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      catppuccin.url = "github:catppuccin/nix";

      # https://github.com/NixOS/nixpkgs/pull/284857
      nixpkgsIdea.url = "github:panda2134/nixpkgs";
    };

    outputs = { self, nixpkgs, nixpkgsUnstable, home-manager, catppuccin, nixpkgsIdea, ...} @ inputs:
      let
        system = "x86_64-linux";

        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        pkgsUnstable = import nixpkgsUnstable {
          inherit system;
          config.allowUnfree = true;
          overlays = import ./overlays;
        };

        pkgsIdea = import nixpkgsIdea {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        nixosConfigurations =
          let
            lib = nixpkgs.lib;
            specialArgs = { inherit pkgs pkgsUnstable; };

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
                  home-manager.extraSpecialArgs = { inherit pkgsUnstable catppuccin; };
                }
              ];
            };

            homer = lib.nixosSystem {
              inherit system specialArgs;
              modules = defaultModules ++ [ ./hosts/homer ];
            };

            marge = lib.nixosSystem {
              inherit system specialArgs;
              modules = defaultModules ++ [ ./hosts/marge ];
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
            extraSpecialArgs = { inherit pkgsUnstable catppuccin pkgsIdea; };
          };
        };
    };
}
