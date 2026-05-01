{ config, lib, inputs, ...}:
with lib;
let
  cfg = config.services.prometheus.exporters.meross;
  pkg = inputs.meross-prometheus-exporter.packages.x86_64-linux.default;
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
        Restart = "always";
        RestartSec = 30;
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
