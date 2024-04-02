{ lib, config, ... }:
with lib;
let
  cfg = config.services.customCaddy;
  
  serviceConfig = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
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
      reverse_proxy http://localhost:${serviceConfig.port}
    }
  '';
in
{
  options.services.customCaddy = {
    enable = mkEnableOption "Custom Caddy service";
    
    domain = mkOption {
      type = types.str;
      description = mdDoc "Domain name to expose";
    };

    lanIP = mkOption {
      type = types.ip;
      description = mdDoc "LAN IP address";
    };

    privateServices = mkOption {
      type = types.listOf serviceConfig;
      default = [];
    };

    publicServices = mkOption {
      type = types.listOf serviceConfig;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "localhost".extraConfig = ''
          respond "Hello from localhost"
        '';

        "*.${cfg.domain}".extraConfig = ''
          tls {
            dns cloudflare Qe10qpYR7d19msYnX9XbyjGJNSH82YEqhBtCaA5t
          }

          log {
            output stdout
          }

          ${concatMapStringsSep "\n" mkServiceConfig cfg.publicServices}

          @out_of_lan not remote_ip ${cfg.lanIP}
          handle @out_of_lan {
            abort
          }

          ${concatMapStringsSep "\n" mkServiceConfig cfg.privateServices}

          handle {
            abort
          }
        '';
      };
    };
  };
  
}
