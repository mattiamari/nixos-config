{
  stdenv,
  fetchzip,
}:
let
  version = "6.1.21";
  hash = "sha256-V6RwbPZHKvGd/FfZsu7mr7EF9zRPMPv58rQvdinf00E=";
in
stdenv.mkDerivation {
  pname = "firefly-iii";
  inherit version;

  src = fetchzip {
    url = "https://github.com/firefly-iii/firefly-iii/releases/download/v${version}/FireflyIII-v${version}.zip";
    sha256 = hash;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out
    cp -r --reflink=auto . $out/
  '';
}
