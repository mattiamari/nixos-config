{
    inputs = {
      nixpkgs.url = "nixpkgs/nixos-23.11";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    };

    outputs = { self, ...} @ inputs:
      let
        system = "x86_64-linux";
      in
      rec {
        inherit (inputs.nixpkgs) lib;
        
        pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
        pkgsUnstable = import inputs.nixpkgsUnstable {
          inherit system;
          config.allowUnfree = true;
          overlays = import ./overlays;
        };


        nixosConfigurations = {

          bart = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/bart ];
            specialArgs = {
              inherit pkgsUnstable;
            };
          };

          homer = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/homer ];
            specialArgs = {
              inherit pkgsUnstable;
            };
          };

          marge = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/marge ];
            specialArgs = {
              inherit pkgsUnstable;
            };
          };

          homertest = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/homer ];
            specialArgs = {
              inherit pkgsUnstable;
            };
          };

          rescusb = lib.nixosSystem {
            inherit system;
            modules = [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./hosts/rescusb
            ];
          };

        };
    };
}
