{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../common
    ../../roles/homeserver
    ./backup.nix
  ];

  nix.settings.trusted-users = [ "mattia" ];

  fileSystems."/".options = [
    "noatime"
    "nodiratime"
  ];
  services.fstrim.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 30;
  };

  # allows using MeshCommander to look at kernel logs
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  #
  # ZFS
  #
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "9b17c09b";
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-01 03:00:00"; # monthly at 3:00
    randomizedDelaySec = "0h";
  };

  networking = {
    hostName = "homer";

    interfaces.eno1 = {
      ipv4.addresses = [
        {
          address = "192.168.0.20";
          prefixLength = 24;
        }
      ];
      useDHCP = false;
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "eno1";
    };

    nameservers = [
      # use Adguard
      # can't use localhost directly because it does not listen on that, to prevent conflicts with podman
      "192.168.0.20"
      "1.1.1.1"
    ];

  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # TODO
  # - (wireguard VPN)
  # - https://github.com/crowdsecurity/crowdsec (o fail2ban)
  # - service hardening
  #   - https://github.com/andir/nixpkgs/commit/4d9c0cfdab5d681ff0372bf8b5a2ac6e650c9b8c
  #   - https://discourse.nixos.org/t/pre-rfc-systemd-hardening/39772

  systemd.services.set-drive-standby =
    let
      disk = "WDC_WD20EZRX-00DC0B0_WD-WCC1T0831876";
    in
    {
      description = "Set standby timeout to backup drive and put it into standby";

      wantedBy = [ "multi-user.target" ];
      after = [ "dev-disk-by-id-ata-${disk}.device" ];
      serviceConfig.Type = "oneshot";

      # Standard -S values do not apply to WD Green drives. "2" seems to be ~30 minutes
      script = "${pkgs.hdparm}/bin/hdparm -S 2 -y /dev/disk/by-id/ata-${disk}";
    };

  homeserver = {
    adminUser = "mattia";
    localIP = "192.168.0.20";
  };

  reverseProxy = {
    publicDomain = "mattiamari.xyz";
    privateDomain = "home.mattiamari.xyz";
    privateNetworkAddr = "192.168.0.0/16";
  };

  system.stateVersion = "23.11";
}
