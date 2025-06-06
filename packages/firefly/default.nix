{
  stdenv,
  fetchzip,
}:
let
  version = "6.2.16";
  hash = "sha256-maqTupnjpaJS3TrpytJiP4sOsm5DNaQwMXaNz6d63uU=";
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
