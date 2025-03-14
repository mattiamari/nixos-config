# from: https://github.com/emilylange/nixos-config/blob/22570786b24b606484447bef7a29fe565d475db7/packages/caddy/default.nix

{ pkgs, ... }:

with pkgs;

caddy.override {
  buildGoModule = args: buildGoModule (args // {
    src = stdenv.mkDerivation rec {
      pname = "caddy-using-xcaddy-${xcaddy.version}";
      inherit (caddy) version;

      dontUnpack = true;
      dontFixup = true;

      nativeBuildInputs = [
        cacert
        go
      ];

      plugins = [
        "github.com/caddy-dns/cloudflare@44030f9306f4815aceed3b042c7f3d2c2b110c97"
      ];

      configurePhase = ''
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        export XCADDY_SKIP_BUILD=1
      '';

      buildPhase = ''
        ${xcaddy}/bin/xcaddy build "${caddy.src.rev}" ${lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins}
        cd buildenv*
        go mod vendor
      '';

      installPhase = ''
        cp -r --reflink=auto . $out
      '';

      outputHash = "sha256-1/TjjhFNIc0woyAn7HigzLtAAdm2Wjm/rn5jgBgekkA=";
      outputHashMode = "recursive";
    };

    subPackages = [ "." ];
    ldflags = [ "-s" "-w" ]; # don't include version info twice
    vendorHash = null;
  });
}
