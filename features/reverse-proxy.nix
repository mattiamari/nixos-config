{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.reverseProxy;

  serviceConfig =
    { name, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
        };
        port = lib.mkOption {
          type = lib.types.port;
        };
        extraConfig = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
    };

  mkServiceConfig = domain: serviceConfig: ''
    @${serviceConfig.name} host ${serviceConfig.name}.${domain}
    handle @${serviceConfig.name} {
      ${serviceConfig.extraConfig}
      reverse_proxy {
        to http://localhost:${toString serviceConfig.port}
      }
    }
  '';
in
{
  options.reverseProxy = {
    enable = lib.mkEnableOption "Enable reverse proxy (Caddy)";

    environmentFilePath = lib.mkOption {
      type = lib.types.path;
      description = "Path to an environment file. Used to pass secrets";
    };

    privateDomain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for private services";
    };

    publicDomain = lib.mkOption {
      type = lib.types.str;
      description = "Domain name for public services";
    };

    privateNetworkAddr = lib.mkOption {
      type = lib.types.str;
      description = "LAN IP address";
    };

    privateServices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule serviceConfig);
      default = { };
      description = "Services accessible only from `lanIP`";
    };

    extraPrivateServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Custom services accessible only from `lanIP`";
    };

    publicServices = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule serviceConfig);
      default = { };
      description = "Services accessible from the internet";
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../packages/caddy { };
      adapter = "caddyfile";

      globalConfig = ''
        # debug
        metrics
      '';

      virtualHosts = {
        "localhost".extraConfig = ''
          respond "Hello from localhost"
        '';
      };

      extraConfig = ''
        *.${cfg.privateDomain} {
          log {
            output file /var/log/caddy/access-${cfg.privateDomain}.log
          }

          tls {
            dns cloudflare {env.CLOUDFLARE_TOKEN}

            # Prevents errors that may arise from the local DNS cache
            resolvers 1.1.1.1
          }

          # Abort connections not coming from LAN
          @out_of_lan not remote_ip ${cfg.privateNetworkAddr}
          handle @out_of_lan {
            abort
          }

          ${lib.concatMapStringsSep "\n" (mkServiceConfig cfg.privateDomain) (lib.attrValues cfg.privateServices)}

          ${lib.concatStringsSep "\n" cfg.extraPrivateServices}

          # Abort requests not handled above
          handle {
            abort
          }
        }

        *.${cfg.publicDomain} {
          log {
            output file /var/log/caddy/access-${cfg.publicDomain}.log
          }

          tls {
            dns cloudflare {env.CLOUDFLARE_TOKEN}

            # Prevents errors that may arise from the local DNS cache
            resolvers 1.1.1.1
          }

          ${lib.concatMapStringsSep "\n" (mkServiceConfig cfg.publicDomain) (lib.attrValues cfg.publicServices)}

          # Abort requests not handled above
          handle {
            abort
          }
        }
      '';
    };

    systemd.services.caddy.serviceConfig = {
      EnvironmentFile = cfg.environmentFilePath;
      ProtectSystem = "full";
      AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      CapabilitiesBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
    };
  };

}
