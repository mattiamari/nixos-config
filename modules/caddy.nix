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

  mkServiceConfig = serviceConfig: ''
    @${serviceConfig.name} host ${serviceConfig.name}.${cfg.domain}
    handle @${serviceConfig.name} {
      ${serviceConfig.extraConfig}
      reverse_proxy http://localhost:${toString serviceConfig.port}
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
    
    domain = mkOption {
      type = types.str;
      description = mdDoc "Domain name to expose";
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
        *.${cfg.domain} {
          log {
            output file /var/log/caddy/access-${cfg.domain}.log
          }

          tls {
            dns cloudflare {env.CLOUDFLARE_TOKEN}

            # Prevents errors that may arise from the local DNS cache
            resolvers 1.1.1.1
          }

          ${concatMapStringsSep "\n" mkServiceConfig (attrValues cfg.publicServices)}

          # Abort connections not coming from LAN
          @out_of_lan not remote_ip ${cfg.privateNetworkAddr}
          handle @out_of_lan {
            abort
          }

          ${concatMapStringsSep "\n" mkServiceConfig (attrValues cfg.privateServices)}

          ${concatStringsSep "\n" cfg.extraPrivateServices}

          # Abort requests not handled above
          handle {
            abort
          }
        }
      '';
    };

    systemd.services.caddy.serviceConfig.EnvironmentFile = cfg.environmentFilePath;
  };
  
}
