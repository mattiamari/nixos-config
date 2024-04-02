{
    description = "";

    inputs = {
      # nixpkgs = { url = "github:NixOS/nixpkgs/nixos-23.11" };
      # or the shorthand
      nixpkgs.url = "nixpkgs/nixos-23.11";
      nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    };

    outputs = { self, nixpkgs, nixpkgsUnstable, ...}:
        let
          lib = nixpkgs.lib;
        in {
        nixosConfigurations = {
          homertest = lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hosts/homer/configuration.nix ];
            specialArgs = { nixpkgsUnstable = nixpkgsUnstable.legacyPackages."x86_64-linux"; };
          };
        };
    };
}
