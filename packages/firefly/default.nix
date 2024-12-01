{
  stdenv,
  fetchzip,
}:
let
  version = "6.1.24";
  hash = "sha256-UOTZ5qgj4FReXEM0GS/RQPmbh6KqpHUVuUwX0m/MrOk=";
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
