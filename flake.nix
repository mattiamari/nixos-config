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
        pkgsUnstable = import inputs.nixpkgsUnstable { inherit system; config.allowUnfree = true; };


        nixosConfigurations = {

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
