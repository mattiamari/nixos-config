{ lib, buildGoModule, ... }:
let
  version = "2.10.2";
in
buildGoModule {
  pname = "caddy";
  inherit version;
  src = ./src;
  vendorHash = "sha256-CaP0DSt5rK8bxlv22lmoPhgULpGalBmd1XCkdG3TXVk=";
  GOFLAGS = [ "-tags=nobadger,nomysql,nopgx" ];

  meta = {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = lib.licenses.asl20;
    mainProgram = "caddy";
  };
}
