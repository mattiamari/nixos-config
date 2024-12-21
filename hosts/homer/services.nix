{ config, lib, pkgs, pkgsUnstable, ... }:
with lib;
let
  myConfig = import ./common.nix;
in
{
  imports = [
    ../../modules/caddy.nix
    ../../modules/qbittorrent.nix
    ../../modules/firefly.nix
    ../../modules/radarr-ita.nix
    ../../modules/sonarr-ita.nix
    ../../modules/filebrowser.nix
    ../../modules/meross-prometheus-exporter.nix
  ];

  networking.firewall = {
    allowedTCPPorts = [
      22000 # syncthing transfers
      50169 # qbittorrent
      1900 # jellyfin DLNA
    ];
    allowedUDPPorts = [
      22000 # syncthing transfers
      21027 # syncthing discovery
      50169 # qbittorrent
      1900 # jellyfin DLNA
    ];
  };

  #
  # Caddy
  #
  myCaddy = {
    enable = true;
    environmentFilePath = "${myConfig.secretsDir}/caddy";
    publicDomain = myConfig.publicHostname;
    privateDomain = myConfig.privateHostname;
    privateNetworkAddr = myConfig.privateNetwork;
  };

  #
  # Services
  #
  services.ddclient = {
    enable = true;
    use = "cmd, cmd='${pkgs.curl}/bin/curl -fs https://ipv4.icanhazip.com'"; # https://github.com/ddclient/ddclient/issues/635#issuecomment-2098950409
    protocol = "cloudflare";
    username = "token";
    passwordFile = "${myConfig.secretsDir}/ddclient-cloudflare-key";
    zone = "mattiamari.xyz";
    domains = [
      "mattiamari.xyz"
      "*.mattiamari.xyz"
    ];
    verbose = true;
  };

  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      # Commenting this so that I can change password in the config file
      # users = [
      #   {
      #     name = myConfig.adminUser;
      #     password = "$2y$10$b2Sozdie36mtEFA3JDpX3eH9rd3tu6hixFkxu5Pd70h9.zxsFxp9i"; # "changeme"
      #   }
      # ];
      filtering = {
        rewrites = [
          { domain = "*.${myConfig.privateHostname}"; answer = myConfig.serverLocalIP; }
          { domain = "*.${myConfig.publicHostname}"; answer = myConfig.serverLocalIP; }
        ];
      };
    };
  };
  myCaddy.privateServices.adguard = {port = 3000;};

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 9000;
        domain = "grafana.home.mattiamari.xyz";
      };
    };
  };
  myCaddy.privateServices.grafana = { port = config.services.grafana.settings.server.http_port; };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "processes" "zfs" ];
        port = 9002;
      };

      meross = {
        enable = true;
        port = 9003;
        secretsFilePath = "${myConfig.secretsDir}/meross";
        scrapeFrequencySeconds = 60;
      };
    };

    globalConfig = {
      scrape_interval = "10s";
    };

    scrapeConfigs = [
      {
        job_name = "homer";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
          ];
        }];
      }
      {
        job_name = "homer_power";
        scrape_interval = "${toString config.services.prometheus.exporters.meross.scrapeFrequencySeconds}s";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.meross.port}"
          ];
        }];
      }
      {
        job_name = "caddy";
        static_configs = [{
          targets = [ "127.0.0.1:2019" ];
        }];
      }
    ];
  };

  services.jellyfin = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.jellyfin;
  };
  myCaddy.privateServices.jellyfin = {port = 8096;};
  environment.systemPackages = [
    pkgsUnstable.jellyfin-web
    pkgsUnstable.jellyfin-ffmpeg
  ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  services.qbittorrent = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8100;
    package = pkgsUnstable.qbittorrent-nox;
  };
  myCaddy.privateServices.qbittorrent = {port = 8100;};

  services.radarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.radarr;
  };
  myCaddy.privateServices.radarr = {port = 7878;};

  services.radarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 7879;
    package = pkgsUnstable.radarr;
  };
  myCaddy.privateServices.radarr-ita = {port = 7879;};

  services.sonarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.sonarr;
  };
  myCaddy.privateServices.sonarr = {port = 8989;};

  services.sonarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8990;
    package = pkgsUnstable.sonarr;
  };
  myCaddy.privateServices.sonarr-ita = {port = 8990;};

  services.prowlarr = {
    enable = true;
    package = pkgsUnstable.prowlarr;
  };
  myCaddy.privateServices.prowlarr = {port = 9696;};

  services.lidarr = {
    enable = true;
    package = pkgsUnstable.lidarr;
    user = "mediaserver";
    group = "mediaserver";
  };
  myCaddy.privateServices.lidarr = { port = 8686; };

  services.bazarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
  };
  myCaddy.privateServices.bazarr = { port = 6767; };

  services.navidrome = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    settings = {
      Port = 4533;
      MusicFolder = "/media/storage/media/music/main";
    };
  };
  myCaddy.publicServices.navidrome = { port = 4533; };

  services.photoprism = {
    enable = true;
    originalsPath = "/media/storage/famiglia/Immagini";
    
    settings = {
      PHOTOPRISM_ADMIN_USER = "admin";
      PHOTOPRISM_ADMIN_PASSWORD = "changeme";
      PHOTOPRISM_SITE_URL = "https://photoprism.home.mattiamari.xyz";
      PHOTOPRISM_FFMPEG_ENCODER = "intel";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "family";
      PHOTOPRISM_DATABASE_NAME = "photoprismfamily";
      PHOTOPRISM_WAKEUP_INTERVAL = "24h";
    };
  };
  myCaddy.privateServices.photoprism = { port = config.services.photoprism.port; };

  systemd.services.photoprism.serviceConfig = {
    User = mkForce "family";
    Group = mkForce "family";
    DynamicUser = mkForce false;
  };

  services.mysql =
  let
    user = config.services.photoprism.settings.PHOTOPRISM_DATABASE_USER;
    db = config.services.photoprism.settings.PHOTOPRISM_DATABASE_NAME;
  in
  {
    ensureDatabases = [ db ];
    ensureUsers = [
      {
        name = user;
        ensurePermissions = { "${db}.*" = "ALL PRIVILEGES"; };
      }
    ];
  };

  services.mysqlBackup.databases = [ config.services.photoprism.settings.PHOTOPRISM_DATABASE_NAME ];

  services.syncthing = {
    enable = true;
  };
  myCaddy.privateServices.syncthing = {
    port = 8384;
    # Prevents "host check error". (https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api)
    extraConfig = ''request_header Host "localhost"'';
  };

  services.firefly = {
    enable = true;
    environmentFilePath = "${myConfig.secretsDir}/firefly";
  };

  services.filebrowser = {
    enable = true;
    port = 7000;
    package = pkgsUnstable.filebrowser;
  };
  myCaddy.publicServices.filebrowser = {
    port = config.services.filebrowser.port;
  };

  users.users.ghostfolio = {
    isSystemUser = true;
    group = "ghostfolio";
    uid = 399;
  };
  users.groups.ghostfolio = {
    gid = 399;
  };

  systemd.services.podman-pod-ghostfolio = {
    description = "Podman Pod Ghostfolio";
    requiredBy = [ "podman-ghostfolio.service" "podman-ghostfolio-redis.service" ];
    before = [ "podman-ghostfolio.service" "podman-ghostfolio-redis.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = "${pkgs.podman}/bin/podman pod create --replace --name=ghostfolio-pod --publish=3333:3333";
    preStop = "${pkgs.podman}/bin/podman pod rm -if ghostfolio-pod";
  };

  virtualisation.oci-containers.containers.ghostfolio = {
    image = "docker.io/ghostfolio/ghostfolio:2.125.0";
    autoStart = true;
    user = "${toString config.users.users.ghostfolio.uid}:${toString config.users.groups.ghostfolio.gid}";
    dependsOn = [ "ghostfolio-redis" ];
    extraOptions = [
      "--pod=ghostfolio-pod"
    ];

    environment = {
      REDIS_HOST = "localhost";
      REDIS_PORT = "6379";
      # REDIS_PASSWORD = "";

      POSTGRES_DB = "ghostfolio";
      POSTGRES_USER = "ghostfolio";
      # POSTGRES_PASSWORD = "";

      DATABASE_URL = "postgresql://ghostfolio@localhost/ghostfolio?host=/var/run/postgresql";
    };

    environmentFiles = [ "${myConfig.secretsDir}/ghostfolio" ];

    volumes = [
      "/var/run/postgresql:/var/run/postgresql"
    ];
  };

  virtualisation.oci-containers.containers.ghostfolio-redis = {
    image = "docker.io/redis:7-alpine";
    autoStart = true;
    extraOptions = [
      "--pod=ghostfolio-pod"
    ];
  };


  myCaddy.privateServices.ghostfolio = { port = 3333; };

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "ghostfolio"
    ];
    ensureUsers = [
      {
        name = "ghostfolio";
        ensureDBOwnership = true;
      }
    ];
  };
}
