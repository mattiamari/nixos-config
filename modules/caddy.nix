{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.homelab.caddy;

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
  options.homelab.caddy = {
    enable = mkEnableOption "Custom Caddy service";
    
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

      virtualHosts = {
        "localhost".extraConfig = ''
          respond "Hello from localhost"
        '';
      };

      # TODO handle secret
      extraConfig = ''
        *.${cfg.domain} {
          log {
            output file /var/log/caddy/access-${cfg.domain}.log
          }

          tls {
            dns cloudflare Qe10qpYR7d19msYnX9XbyjGJNSH82YEqhBtCaA5t
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
  };
  
}
