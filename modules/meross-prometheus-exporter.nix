{ config, lib, pkgs, ...}:
with lib;
let
  cfg = config.services.prometheus.exporters.meross;
  pkg = pkgs.callPackage ../packages/meross-prometheus-exporter {};
in
{ 
   options.services.prometheus.exporters.meross = {
    enable = mkEnableOption (mdDoc "Meross Prometheus Exporter");

    port = mkOption {
      type = types.port;
    };

    secretsFilePath = mkOption {
      type = types.str;
    };

    scrapeFrequencySeconds = mkOption {
      type = types.int;
      default = 300;
    };

    merossApiUrl = mkOption {
      type = types.str;
      default = "https://iotx-eu.meross.com";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.meross-prometheus-exporter = {
      enable = true;

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        WorkingDirectory = pkg;
        EnvironmentFile = cfg.secretsFilePath;
        ExecStart = ''
          ${pkg}/start
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };

      environment = {
        METRICS_PORT = toString cfg.port;
        METRICS_FREQ_SECONDS = toString cfg.scrapeFrequencySeconds;
        MEROSS_BASE_URL = cfg.merossApiUrl;
        LOG_LEVEL = "10";
      };

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
  };
}
