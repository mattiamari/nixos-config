{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  imports = [
    ../../modules/firefly.nix
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
  # Services
  #
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
  reverseProxy.privateServices.photoprism.port = config.services.photoprism.port;

  systemd.services.photoprism.serviceConfig = {
    User = mkForce "family";
    Group = mkForce "family";
    DynamicUser = mkForce false;
  };

  services.mysql =
    let
      db = config.services.photoprism.settings.PHOTOPRISM_DATABASE_NAME;
    in
    {
      ensureDatabases = [ db ];
      ensureUsers = [
        {
          name = config.services.photoprism.settings.PHOTOPRISM_DATABASE_USER;
          ensurePermissions = {
            "${db}.*" = "ALL PRIVILEGES";
          };
        }
      ];
    };

  services.mysqlBackup.databases = [ config.services.photoprism.settings.PHOTOPRISM_DATABASE_NAME ];

  services.syncthing = {
    enable = true;
  };
  reverseProxy.privateServices.syncthing = {
    port = 8384;
    # Prevents "host check error". (https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api)
    extraConfig = ''request_header Host "localhost"'';
  };

  services.firefly = {
    enable = true;
    environmentFilePath = "${config.homeserver.secretsDir}/firefly";
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
    requiredBy = [
      "podman-ghostfolio.service"
      "podman-ghostfolio-redis.service"
    ];
    before = [
      "podman-ghostfolio.service"
      "podman-ghostfolio-redis.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = "${pkgs.podman}/bin/podman pod create --replace --name=ghostfolio-pod --publish=3333:3333";
    preStop = "${pkgs.podman}/bin/podman pod rm -if ghostfolio-pod";
  };

  virtualisation.oci-containers.containers.ghostfolio = {
    image = "docker.io/ghostfolio/ghostfolio:2.205.0";
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

    environmentFiles = [ "${config.homeserver.secretsDir}/ghostfolio" ];

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

  reverseProxy.privateServices.ghostfolio.port = 3333;

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = "${config.homeserver.secretsDir}/miniflux";
    config = {
      BASE_URL = "https://miniflux.${config.reverseProxy.privateDomain}";
    };
  };
  reverseProxy.privateServices.miniflux.port = 8080;

  services.shiori = {
    enable = true;
    databaseUrl = "postgres:///shiori?host=/run/postgresql";
    port = 8081;
  };
  reverseProxy.privateServices.shiori.port = 8081;

  services.postgresql = {
    ensureDatabases = [
      "ghostfolio"
      "shiori"
    ];
    ensureUsers = [
      {
        name = "ghostfolio";
        ensureDBOwnership = true;
      }
      {
        name = "shiori";
        ensureDBOwnership = true;
      }
    ];
  };
  services.postgresqlBackup.databases = [
    "ghostfolio"
    "miniflux"
    "shiori"
  ];

  services.calibre-web = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    options = {
      calibreLibrary = "/media/storage/media/calibre-books";
    };
  };
  reverseProxy.privateServices.calibre.port = 8083;
}
