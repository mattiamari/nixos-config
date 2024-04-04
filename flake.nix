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
          pkgs = nixpkgs.legacyPackages.${system};
          pkgsUnstable = nixpkgsUnstable.legacyPackages.${system};
        in {
        nixosConfigurations = {
          homertest = lib.nixosSystem {
            inherit system;
            modules = [ ./hosts/homer/configuration.nix ];
            specialArgs = {
              inherit pkgsUnstable;
            };
          };
        };
    };
}
