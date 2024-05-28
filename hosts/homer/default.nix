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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 30;
  };

  #
  # ZFS
  #
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "9b17c09b";
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-01 03:00"; # monthly at 3:00
  };

  networking = {
    hostName = "homer";

    networkmanager.enable = true;
    networkmanager.insertNameservers = [ "1.1.1.1" ];

    resolvconf.useLocalResolver = false;

    nftables.enable = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 53 80 443 853 ];
      allowedUDPPorts = [ 53 443 853 ];
    };
  };

  users.users.${myConfig.adminUser} = {
    isNormalUser = true;
    description = "Admin";
    uid = 1000;
    group = myConfig.adminUser;
    extraGroups = [ myConfig.adminUser "networkmanager" "wheel" "family" "mediaserver" "syncthing" ];
    packages = [];
    shell = pkgs.zsh;
    # linger = true;
  };
  users.groups.${myConfig.adminUser} = {
    gid = 1000;
  };

  users.users.family = {
    isNormalUser = true;
    description = "family";
    group = "family";
    uid = 1001;
  };
  users.groups.family = {
    gid = 1001;
  };

  users.users.mediaserver = {
    isSystemUser = true;
    group = "mediaserver";
    uid = 993;
  };
  users.groups.mediaserver = {
    gid = 993;
  };

  environment.systemPackages = with pkgs; [
    shadow
    hdparm
  ];

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

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = config.services.mysqlBackup.user;
        ensurePermissions = { "*.*" = "SELECT, LOCK TABLES"; };
      }
    ];
  };

  services.mysqlBackup = {
    enable = true;
    calendar = "*-*-* 01:00";
  };

  # TODO
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

  systemd.services.set-drive-standby = let disk = "WDC_WD20EZRX-00DC0B0_WD-WCC1T0831876"; in {
    description = "Set standby timeout to backup drive and put it into standby";

    wantedBy = [ "multi-user.target" ];
    after = [ "dev-disk-by-id-ata-${disk}.device" ];
    serviceConfig.Type = "oneshot";

    # Standard -S values do not apply to WD Green drives. "2" seems to be ~30 minutes
    script = "${pkgs.hdparm}/bin/hdparm -S 2 -y /dev/disk/by-id/ata-${disk}";
  };

  system.stateVersion = "23.11";
}
