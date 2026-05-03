{ config, lib, inputs, ...}:
let
  cfg = config.services.prometheus.exporters.meross;
  pkg = inputs.meross-prometheus-exporter.packages.x86_64-linux.default;
in
{
  options.services.prometheus.exporters.meross = {
    enable = lib.mkEnableOption "Meross Prometheus Exporter";

    port = lib.mkOption {
      type = lib.types.port;
    };

    secretsFilePath = lib.mkOption {
      type = lib.types.str;
    };

    scrapeFrequencySeconds = lib.mkOption {
      type = lib.types.int;
      default = 300;
    };

    merossApiUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://iotx-eu.meross.com";
    };
  };

  config = lib.mkIf cfg.enable {
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
