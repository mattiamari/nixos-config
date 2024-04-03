{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.homelab.caddy;

  serviceConfig = {name, ...}: {
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

    lanIP = mkOption {
      type = types.str;
      description = mdDoc "LAN IP address";
    };

    privateServices = mkOption {
      type = types.attrsOf (types.submodule serviceConfig);
      default = {};
    };

    publicServices = mkOption {
      type = types.attrsOf (types.submodule serviceConfig);
      default = {};
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

        "*.${cfg.domain}".extraConfig = ''
          tls {
            dns cloudflare Qe10qpYR7d19msYnX9XbyjGJNSH82YEqhBtCaA5t
          }

          log {
            output stdout
          }

          ${concatMapStringsSep "\n" mkServiceConfig (attrValues cfg.publicServices)}

          @out_of_lan not remote_ip ${cfg.lanIP}
          handle @out_of_lan {
            abort
          }

          ${concatMapStringsSep "\n" mkServiceConfig (attrValues cfg.privateServices)}

          handle {
            abort
          }
        '';
      };
    };
  };
  
}
