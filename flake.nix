{
    description = "";

    inputs = {
      nixpkgs.url = "nixpkgs/nixos-23.11";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgsUnstable, ...}:
        let
          lib = nixpkgs.lib;
          system = "x86_64-linux";
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          pkgsUnstable = import nixpkgsUnstable { inherit system; config.allowUnfree = true; };
        in {
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
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./hosts/rescusb
            ];
          };
        };
    };
}
