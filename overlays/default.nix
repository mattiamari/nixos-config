{ pkgsStable, nixpkgs-2411 }:

final: prev: {
  # Fix for buggy nwjs that breaks betaflight configurator
  nwjs = prev.nwjs.overrideAttrs {
    version = "0.84.0";
    src = prev.fetchurl {
      url = "https://dl.nwjs.io/v0.84.0/nwjs-v0.84.0-linux-x64.tar.gz";
      hash = "sha256-VIygMzCPTKzLr47bG1DYy/zj0OxsjGcms0G1BkI/TEI=";
    };
  };

  lasuite-docs-collaboration-server = prev.stdenv.mkDerivation {
    pname = "lasuite-docs-collaboration-server";
    version = "0.0.0-fake";
    src = prev.emptyTree;
    installPhase = "mkdir -p $out";
  };
  lasuite-docs = prev.stdenv.mkDerivation {
    pname = "lasuite-docs";
    version = "0.0.0-fake";
    src = prev.emptyTree;
    installPhase = "mkdir -p $out";
  };

  torzu = nixpkgs-2411.legacyPackages.${prev.system}.torzu;

  photoprism = pkgsStable.photoprism;

  jetbrains.idea-ultimate = pkgsStable.jetbrains.idea-ultimate;
}
