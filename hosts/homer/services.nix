{ config, pkgs, pkgsUnstable, ... }:
let
  myConfig = import ./common.nix;
in
{
  imports =
    [
      ../../modules/caddy.nix
      ../../modules/qbittorrent.nix
      ../../modules/firefly.nix
      ../../modules/radarr-ita.nix
      ../../modules/sonarr-ita.nix
      ../../modules/filebrowser.nix
    ];

  #
  # Caddy
  #
  myCaddy = {
    enable = true;
    environmentFilePath = "${myConfig.secretsDir}/caddy";
    domain = myConfig.publicHostname;
    privateNetworkAddr = myConfig.privateNetwork;
  };

  #
  # Services
  #
  services.ddclient = {
    enable = true;
    use = "web, web=icanhazip.com";
    protocol = "cloudflare";
    username = "token";
    passwordFile = "${myConfig.secretsDir}/ddclient-cloudflare-key";
    zone = "mattiamari.xyz";
    domains = [
      "mattiamari.xyz"
      "*.mattiamari.xyz"
    ];
  };

  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      users = [
        {
          name = myConfig.adminUser;
          password = "$2y$10$b2Sozdie36mtEFA3JDpX3eH9rd3tu6hixFkxu5Pd70h9.zxsFxp9i"; # "changeme"
        }
      ];
      dns = {
        rewrites = [
          { domain = "*.${myConfig.publicHostname}"; answer = myConfig.serverLocalIP; }
        ];
      };
    };
  };
  myCaddy.privateServices.adguard = {port = 3000;};

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
  hardware.opengl = {
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

  # # TODO configure
  # services.photoprism = {
  #   enable = false;
  #   originalsPath = /tmp/photoprism;
    
  #   # settings = {
  #   #
  #   # };
  # };

  services.syncthing = {
    enable = true;
  };
  myCaddy.privateServices.syncthing = {
    port = 8384;
    # Prevents "host check error". (https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api)
    extraConfig = ''request_header Host "localhost"'';
  };

  # TODO 50169 is for qbittorrent. Move syncthing to its own module
  # 22000: transfers, 21027: discovery
  networking.firewall = {
    allowedTCPPorts = [ 22000 50169 ];
    allowedUDPPorts = [ 21027 22000 50169 ];
  };

  services.firefly = {
    enable = true;
    environmentFilePath = "${myConfig.secretsDir}/firefly";
  };

  # services.filebrowser = {
  #   enable = true;
  #   port = 9001;
  #   package = pkgsUnstable.filebrowser;
  # };
  # myCaddy.publicServices.filebrowser = {
  #   port = config.services.filebrowser.port;
  # };
}
