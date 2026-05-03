{ config, ... }:
{
  imports = [
    ../../modules/meross-prometheus-exporter.nix
  ];

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 9000;
        domain = "grafana.${config.reverseProxy.privateDomain}";
      };

      security = {
        secret_key = "$__file{/run/credentials/grafana.service/secret-key}";
      };
    };
  };
  reverseProxy.privateServices.grafana = {
    port = config.services.grafana.settings.server.http_port;
  };
  systemd.services.grafana = {
    serviceConfig = {
      LoadCredential = [
        "secret-key:${config.homeserver.secretsDir}/grafana-secret-key"
      ];
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [
          "systemd"
          "processes"
          "zfs"
        ];
        port = 9002;
      };

      meross = {
        enable = true;
        port = 9003;
        secretsFilePath = "${config.homeserver.secretsDir}/meross";
        scrapeFrequencySeconds = 60;
      };
    };

    globalConfig = {
      scrape_interval = "10s";
    };

    scrapeConfigs = [
      {
        job_name = "homer";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      {
        job_name = "homer_power";
        scrape_interval = "${toString config.services.prometheus.exporters.meross.scrapeFrequencySeconds}s";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.meross.port}"
            ];
          }
        ];
      }
      {
        job_name = "caddy";
        static_configs = [
          {
            targets = [ "127.0.0.1:2019" ];
          }
        ];
      }
    ];
  };

}
