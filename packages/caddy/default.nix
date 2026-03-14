{ lib, buildGoModule, ... }:
let
  version = "2.11.1";
in
buildGoModule {
  pname = "caddy";
  inherit version;
  src = ./src;
  vendorHash = "sha256-NVAUEE4Mi1l1/p4vRdDpBcBjfU+E6yuNv9aTpnE4Mps=";

  meta = {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = lib.licenses.asl20;
    mainProgram = "caddy";
  };
}
