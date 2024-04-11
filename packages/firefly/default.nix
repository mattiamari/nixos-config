{
  stdenv,
  fetchzip,
}:
let
  version = "6.1.13";
  hash = "sha256-97ml3b19IJd70xGDnvBwLUJSw3Ms4BL3qGQ62KLTyFE=";
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
    cp -r . $out/
  '';
}
