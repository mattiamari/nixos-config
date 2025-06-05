{ lib, buildGoModule, ... }:
let
  version = "2.10.0";
in
buildGoModule {
  pname = "caddy";
  inherit version;
  src = ./src;
  vendorHash = "sha256-N+w72Q6/yfqHf2YScmZ/7U8TWyu9xG6O/0YnKEhChhQ=";

  meta = {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = lib.licenses.asl20;
    mainProgram = "caddy";
  };
}
