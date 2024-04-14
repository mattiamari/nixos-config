{ config, pkgs, pkgsUnstable, ... }:

let
  publicHostname = "test.mattiamari.xyz";
  serverLocalIP = "192.168.122.46";
  privateNetwork = "192.168.0.0/16";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/caddy.nix
      ../../modules/qbittorrent.nix
      ../../modules/firefly.nix
      ../../modules/radarr-ita.nix
      ../../modules/sonarr-ita.nix
      ../../modules/filebrowser.nix
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" ];

  services.fstrim.enable = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = false;

  boot.tmp.useTmpfs = true;

  networking.hostName = "homertest";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.resolvconf.useLocalResolver = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "it";
    xkbVariant = "it";
  };

  # Configure console keymap
  console.keyMap = "it";

  users.users.mattia = {
    isNormalUser = true;
    description = "Mattia";
    group = "mattia";
    extraGroups = [ "networkmanager" "wheel" "family" "mediaserver" "syncthing" ];
    packages = [];
    shell = pkgs.zsh;
    # linger = true;
  };
  users.groups.mattia = {};

  users.users.family = {
    isNormalUser = true;
    description = "family";
    group = "family";
  };
  users.groups.family = {};

  users.users.mediaserver = {
    isSystemUser = true;
    group = "mediaserver";
  };
  users.groups.mediaserver = {};

  environment.systemPackages = with pkgs; [
    shadow
    wget
    git
    btop
    gdu
    tree
    zip
    podman-compose
    pkgsUnstable.jellyfin-ffmpeg
    mysql-client
    helix
    nil # Nix language server
  ];

  programs.zsh.enable = true;
  programs.tmux = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 53 80 443 ];
    allowedUDPPorts = [ 53 443 ];
  };

  #
  # Caddy
  #
  homelab.caddy = {
    enable = true;
    domain = publicHostname;
    privateNetworkAddr = privateNetwork;
  };

  # TODO
  # - backup script
  # - grafana + prometheus
  # - (wireguard VPN)
  # - https://github.com/crowdsecurity/crowdsec (o fail2ban) 
  # - key-only ssh login
  # - service hardening
  #   - https://github.com/andir/nixpkgs/commit/4d9c0cfdab5d681ff0372bf8b5a2ac6e650c9b8c
  #   - https://discourse.nixos.org/t/pre-rfc-systemd-hardening/39772

  #
  # SMB
  #
  services.samba = {
    enable = true;
    openFirewall = true;
    enableNmbd = true;
    extraConfig = ''
      guest account = nobody
      map to guest = bad user
      server min protocol = SMB3
      server smb encrypt = desired
    '';
    shares = {
      storage = {
        path = "/media/storage";
        writable = true;
        browseable = true;
        "guest ok" = false;
        "valid users" = "mattia";
      };
      family = {
        path = "/media/storage/family";
        writable = true;
        browseable = true;
        "guest ok" = false;
        "valid users" = "@family";
      };
      media = {
        path = "/media/storage/media";
        "read only" = true;
        browseable = true;
        "guest ok" = true;
      };
    };
  };

  #
  # Services
  #
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [
      "firefly"
    ];
    ensureUsers = [
      {
        name = "firefly";
        ensurePermissions = {
          "firefly.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.ddclient = {
    enable = true;
    use = "web, web=icanhazip.com";
    protocol = "cloudflare";
    username = "token";
    passwordFile = "/home/mattia/secrets/ddclient_token";
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
          name = "mattia";
          password = "$2y$10$b2Sozdie36mtEFA3JDpX3eH9rd3tu6hixFkxu5Pd70h9.zxsFxp9i"; # "changeme"
        }
      ];
      dns = {
        rewrites = [
          {domain = "*.${publicHostname}"; answer = serverLocalIP;}
        ];
      };
    };
  };
  homelab.caddy.privateServices.adguard = {port = 3000;};

  services.jellyfin = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.jellyfin;
  };
  homelab.caddy.privateServices.jellyfin = {port = 8096;};

  services.qbittorrent = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8100;
  };
  homelab.caddy.privateServices.qbittorrent = {port = 8100;};

  services.radarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.radarr;
  };
  homelab.caddy.privateServices.radarr = {port = 7878;};

  services.radarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 7879;
    package = pkgsUnstable.radarr;
  };
  homelab.caddy.privateServices.radarr-ita = {port = 7879;};

  services.sonarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = pkgsUnstable.sonarr;
  };
  homelab.caddy.privateServices.sonarr = {port = 8989;};

  services.sonarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8990;
    package = pkgsUnstable.sonarr;
  };
  homelab.caddy.privateServices.sonarr-ita = {port = 8990;};

  services.prowlarr = {
    enable = true;
    package = pkgsUnstable.prowlarr;
  };
  homelab.caddy.privateServices.prowlarr = {port = 9696;};

  # TODO configure
  services.photoprism = {
    enable = false;
    originalsPath = /tmp/photoprism;
    
    # settings = {
    #
    # };
  };

  services.syncthing = {
    enable = true;
  };
  homelab.caddy.privateServices.syncthing = {
    port = 8384;
    # Prevents "host check error". (https://docs.syncthing.net/users/faq.html#why-do-i-get-host-check-error-in-the-gui-api)
    extraConfig = ''request_header Host "localhost"'';
  };

  services.firefly = {
    enable = true;
  };

  services.filebrowser = {
    enable = true;
    port = 9001;
    package = pkgsUnstable.filebrowser;
  };
  homelab.caddy.publicServices.filebrowser = {
    port = config.services.filebrowser.port;
  };

  #
  # Containers
  #
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
