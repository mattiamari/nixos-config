{ pkgs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
    ./smb.nix
  ];

  nix.settings.trusted-users = [ "mattia" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "pool" ];
  networking.hostId = "5493c00f";

  networking.hostName = "marge";
  networking.networkmanager.enable = true;

  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  console.keyMap = "it";

  users.users.mattia = {
    isNormalUser = true;
    description = "Mattia";
    extraGroups = [
      "networkmanager"
      "wheel"
      "cdrom"
    ];
    packages = with pkgs; [ ];
  };

  environment.systemPackages = with pkgs; [
    abcde
  ];

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
