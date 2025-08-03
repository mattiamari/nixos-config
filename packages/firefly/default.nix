{
  stdenv,
  fetchzip,
}:
let
  version = "6.2.21";
  hash = "sha256-kcmWp8ctdp25Z+uqeWbAl3vpuU8m8tQBQFzMn1LOi7U=";
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
