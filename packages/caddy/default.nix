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
        "github.com/caddy-dns/cloudflare@e52afcd970f5655d702396bea5b3f99a7500f1a8"
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

      outputHash = "sha256-O0DnxJ+jpfo19kgwb56PCU8DRvcHtRNsfsrTqfQbyns=";
      outputHashMode = "recursive";
    };

    subPackages = [ "." ];
    ldflags = [ "-s" "-w" ]; # don't include version info twice
    vendorHash = null;
  });
}
