{
    inputs = {
      nixpkgs.url = "nixpkgs/nixos-23.11";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager/release-23.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { self, nixpkgs, nixpkgsUnstable, home-manager, ...} @ inputs:
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
                ./hosts/bart
                home-manager.nixosModules.home-manager
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
            modules = [ ./home-manager/mattia.nix ];
            extraSpecialArgs = { inherit pkgsUnstable; };
          };
        };
    };
}
