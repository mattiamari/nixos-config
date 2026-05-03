{ pkgs, ... }:

{
  imports = [
    ../common
    ./hardware-configuration.nix
    ./smb.nix
  ];

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

  # Allow root login with key for ZFS receive
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  system.stateVersion = "23.11";
}
