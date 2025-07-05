{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./smb.nix
  ];

  nix.settings.trusted-users = ["mattia"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "pool" ];
  networking.hostId = "5493c00f";

  networking.hostName = "marge";
  networking.networkmanager.enable = true;

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
    xkbVariant = "";
  };

  console.keyMap = "it";

  users.users.mattia = {
    isNormalUser = true;
    description = "Mattia";
    extraGroups = [ "networkmanager" "wheel" "cdrom" ];
    packages = with pkgs; [];
  };

  environment.systemPackages = with pkgs; [
    rsync
    smartmontools
    hdparm
    tmux
    htop
    gdu
    helix
    abcde
  ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  services.openssh = {
    enable = true;
    settings = {
      # Allow root login with key for ZFS receive
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "23.11";
}
