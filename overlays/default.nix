[
  (final: prev: {
    filebrowser = let
      overrideVersion = "2.27.0";

      src = prev.fetchFromGitHub {
        owner = "filebrowser";
        repo = "filebrowser";
        rev = "v${overrideVersion}";
        hash = "sha256-3dQUoPd+L1ndluxsH8D48WEmRUFypOqIiFfN2LbAq1U=";
      };

      frontend = prev.buildNpmPackage rec {
        pname = "filebrowser-frontend";
        version = overrideVersion;

        inherit src;

        sourceRoot = "${src.name}/frontend";

        npmDepsHash = "sha256-PB2XCXVYqlZWJtlptxyFK1PTiyJI5nq0tjunkRaLf5E=";

        NODE_OPTIONS = "--openssl-legacy-provider";

        installPhase = ''
          runHook preInstall

          mkdir $out
          mv dist $out

          runHook postInstall
        '';
      };
    in prev.buildGoModule {
      pname = "filebrowser";
      version = overrideVersion;
      inherit src;

      vendorHash = "sha256-vgw3LvRwD8sTpDAxFYVVJY6+rlMH5C5qv2U2UO/me1w=";

      excludedPackages = [ "tools" ];

      preBuild = ''
        cp -r ${frontend}/dist frontend/
      '';

      passthru = {
        inherit frontend;
      };
    };
  })
]
