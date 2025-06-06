{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myCaddy;

  serviceConfig = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };
      port = mkOption {
        type = types.port;
      };
      extraConfig = mkOption {
        type = types.str;
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
  options.myCaddy = {
    enable = mkEnableOption "Custom Caddy service";

    environmentFilePath = mkOption {
      type = types.path;
      description = mdDoc "Path to an environment file. Used to pass secrets";
    };
    
    privateDomain = mkOption {
      type = types.str;
      description = mdDoc "Domain name for private services";
    };

    publicDomain = mkOption {
      type = types.str;
      description = mdDoc "Domain name for public services";
    };

    privateNetworkAddr = mkOption {
      type = types.str;
      description = mdDoc "LAN IP address";
    };

    privateServices = mkOption {
      type = types.attrsOf (types.submodule serviceConfig);
      default = {};
      description = mdDoc "Services accessible only from `lanIP`";
    };

    extraPrivateServices = mkOption {
      type = types.listOf types.str;
      default = [];
      description = mdDoc "Custom services accessible only from `lanIP`";
    };

    publicServices = mkOption {
      type = types.attrsOf (types.submodule serviceConfig);
      default = {};
      description = mdDoc "Services accessible from the internet";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../packages/caddy {};

      globalConfig = ''
        servers {
          metrics
        }
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

          ${concatMapStringsSep "\n" (mkServiceConfig cfg.privateDomain) (attrValues cfg.privateServices)}

          ${concatStringsSep "\n" cfg.extraPrivateServices}

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

          ${concatMapStringsSep "\n" (mkServiceConfig cfg.publicDomain) (attrValues cfg.publicServices)}

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
