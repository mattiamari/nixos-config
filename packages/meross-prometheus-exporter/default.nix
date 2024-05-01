{ stdenv, pkgs }:

let
  pname = "meross-prometheus-exporter";
  version = "1.0.1";

  python = pkgs.python311.withPackages (ps: with ps; [
    setuptools
    meross-iot
    prometheus-client
  ]);

  startScript = pkgs.writeShellScript "meross-prometheus-exporter-start" ''
    ${python}/bin/python main.py
  '';
in

stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchFromGitHub {
    owner = "mattiamari";
    repo = "meross-prometheus-exporter";
    rev = "v${version}";
    sha256 = "sha256-SzBSwP2S8iFL0GrqXHtPHTtM3snSlhZjef1EmU+lJa0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r src/. $out/
    install -m 0755 ${startScript} $out/start
  '';

  doCheck = false;
}
