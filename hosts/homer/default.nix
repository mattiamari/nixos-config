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

  fileSystems."/media/storage" = {
    device = "/dev/disk/by-uuid/48ad7158-f929-41a4-83fb-30ff769edcf2";
    fsType = "ext4";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.useTmpfs = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 30;
  };

  networking.hostName = "homer";
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [ "1.1.1.1" ];
  networking.resolvconf.useLocalResolver = false;

  time.timeZone = "Europe/Rome";

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

  services.xserver = {
    layout = "it";
    xkbVariant = "it";
  };

  console.keyMap = "it";

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
    wget
    git
    btop
    htop
    smartmontools
    hdparm
    gdu
    tree
    zip
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
  };

  systemd.services.set-drive-standby = let disk = "WDC_WD20EZRX-00DC0B0_WD-WCC1T0831876"; in {
    description = "Set standby timeout to backup drive and put it into standby";

    wantedBy = [ "multi-user.target" ];
    after = [ "dev-disk-by-id-ata-${disk}.device" ];
    serviceConfig.Type = "oneshot";

    # 120 = 10 minutes
    script = "${pkgs.hdparm}/bin/hdparm -S 120 -y /dev/disk/by-id/ata-${disk}";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11";
}
