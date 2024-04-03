# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, nixpkgsUnstable,... }:

let
  publicHostname = "test.mattiamari.xyz";
  lanIPAddr = "192.168.122.46";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/qbittorrent.nix
      ../../modules/firefly.nix
      ../../modules/radarr-ita.nix
      ../../modules/sonarr-ita.nix
      ../../modules/caddy.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = false;

  networking.hostName = "homertest"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mattia = {
    isNormalUser = true;
    description = "Mattia";
    extraGroups = [ "networkmanager" "wheel" "famiglia" "mediaserver" "syncthing" ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
    linger = true;
  };

  users.users.famiglia = {
    isNormalUser = true;
    description = "famiglia";
  };

  users.users.mediaserver = {
    isSystemUser = true;
    group = "mediaserver";
  };
  users.groups.mediaserver = {};

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    shadow
    wget
    git
    btop
    gdu
    tree
    zip
    cargo
    gcc
    podman-compose
    nixpkgsUnstable.jellyfin-ffmpeg
    mysql-client
    helix
    nil
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
    domain = "test.mattiamari.xyz";
    lanIP = "192.168.0.0/16";
  };

  # TODO
  # user: mediaserver, group: mediaserver
  #   - jellyfin, qbittorrent, radarr, radarrIta, sonarr, sonarrIta, prowlarr
  # - syncthing
  # - photoprism
  # - adguard home
  # - ddclient
  # - configurazione caddy + ssl (possibilmente senza dover aprire 80 e 443)
  #   - https://github.com/emilylange/nixos-config/blob/22570786b24b606484447bef7a29fe565d475db7/packages/caddy/default.nix
  #   - https://letsencrypt.org/docs/challenge-types/#dns-01-challenge
  # - wireguard VPN
  # - samba
  # - https://github.com/crowdsecurity/crowdsec (o fail2ban) 

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
    passwordFile = "/home/mattia/nixos/ddclient_token";
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
          {domain = "*.${publicHostname}"; answer = lanIPAddr;}
        ];
      };
    };
  };
  homelab.caddy.privateServices.adguard = {port = 3000;};

  services.jellyfin = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = nixpkgsUnstable.jellyfin;
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
    package = nixpkgsUnstable.radarr;
  };
  homelab.caddy.privateServices.radarr = {port = 7878;};

  services.radarrIta = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 7879;
    package = nixpkgsUnstable.radarr;
  };
  homelab.caddy.privateServices.radarr-ita = {port = 7879;};

  services.sonarr = {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    package = nixpkgsUnstable.sonarr;
  };
  homelab.caddy.privateServices.sonarr = {port = 8989;};

  services.sonarrIta= {
    enable = true;
    user = "mediaserver";
    group = "mediaserver";
    port = 8990;
    package = nixpkgsUnstable.sonarr;
  };
  homelab.caddy.privateServices.sonarr-ita = {port = 8990;};

  services.prowlarr = {
    enable = true;
    package = nixpkgsUnstable.prowlarr;
  };
  homelab.caddy.privateServices.prowlarr = {port = 9696;};

  services.photoprism = {
    enable = false;
    originalsPath = /tmp/photoprism;
    # TODO    
    
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

  homelab.caddy.privateServices.firefly = {port = 8097;};

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
