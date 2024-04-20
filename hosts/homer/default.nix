{ config, pkgs, pkgsUnstable, ... }:

let
  myConfig = import ./common.nix;
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./backup.nix
      ./smb.nix
      ./services.nix
    ];

  fileSystems."/".options = [ "noatime" "nodiratime" ];
  services.fstrim.enable = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = false;

  boot.tmp.useTmpfs = true;

  networking.hostName = "homertest";
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

  users.users.${myConfig.adminUser} = {
    isNormalUser = true;
    description = "Admin";
    group = myConfig.adminUser;
    extraGroups = [ "networkmanager" "wheel" "family" "mediaserver" "syncthing" ];
    packages = [];
    shell = pkgs.zsh;
    # linger = true;
  };
  users.groups.${myConfig.adminUser} = {
    gid = 991;
  };

  users.users.family = {
    isNormalUser = true;
    description = "family";
    group = "family";
    uid = 1001;
  };
  users.groups.family = {
    gid = 992;
  };

  users.users.mediaserver = {
    isSystemUser = true;
    group = "mediaserver";
    uid = 994;
  };
  users.groups.mediaserver = {
    gid = 993;
  };

  environment.systemPackages = with pkgs; [
    shadow
    wget
    git
    btop
    gdu
    tree
    zip
    borgbackup
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

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 53 80 443 ];
    allowedUDPPorts = [ 53 443 ];
  };

  # TODO
  # - grafana + prometheus
  # - (wireguard VPN)
  # - https://github.com/crowdsecurity/crowdsec (o fail2ban) 
  # - service hardening
  #   - https://github.com/andir/nixpkgs/commit/4d9c0cfdab5d681ff0372bf8b5a2ac6e650c9b8c
  #   - https://discourse.nixos.org/t/pre-rfc-systemd-hardening/39772

  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11";
}
